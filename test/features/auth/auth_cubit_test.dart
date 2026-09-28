import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_chat_app/features/auth/data/auth_service.dart';
import 'package:simple_chat_app/features/auth/presentation/cubit/auth_cubit.dart';

import '../../helpers/fake_firebase.dart';

void main() {
  late FakeFirebase firebase;
  late AuthCubit cubit;

  setUp(() {
    firebase = FakeFirebase();
    cubit = AuthCubit(
      authService: AuthService(
        auth: firebase.auth,
        firestore: firebase.firestore,
      ),
    );
  });

  tearDown(() => cubit.close());

  /// Runs [action] and returns every state the cubit emitted meanwhile.
  Future<List<AuthState>> record(Future<void> Function() action) async {
    final states = <AuthState>[];
    final subscription = cubit.stream.listen(states.add);
    await action();
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();
    return states;
  }

  Matcher error(String message) =>
      isA<AuthError>().having((state) => state.message, 'message', message);

  Future<void> register() => cubit.registerWithEmailAndPassword(
    fullName: '  Ada Lovelace ',
    email: ' ada@b.com ',
    password: ' secret1 ',
  );

  test('starts in the initial state', () {
    expect(cubit.state, isA<AuthInitial>());
  });

  group('registerWithEmailAndPassword', () {
    test('emits loading then success with the new user', () async {
      final states = await record(register);

      expect(states, [
        isA<AuthLoading>(),
        isA<AuthSuccess>().having((s) => s.user.uid, 'uid', 'new-uid'),
      ]);
    });

    test('follows the session order with trimmed values', () async {
      await register();

      expect(firebase.calls, [
        'createUser|ada@b.com|secret1',
        'updateDisplayName|Ada Lovelace',
        'sendEmailVerification',
        'firestore.set|users/new-uid',
      ]);
    });

    test('leaves the new user signed in but not verified', () async {
      await register();

      expect(cubit.currentUser?.displayName, 'Ada Lovelace');
      expect(cubit.currentUser?.emailVerified, isFalse);
    });

    test(
      'saves the profile in users/{uid}, merged, without a password',
      () async {
        await register();

        expect(firebase.documents['users/new-uid'], {
          'email': 'ada@b.com',
          'name': 'Ada Lovelace',
          'image': null,
          'uid': 'new-uid',
        });
        expect(firebase.writeOptions['users/new-uid']?.merge, isTrue);
      },
    );

    test('shows the friendly message and saves nothing on failure', () async {
      firebase.nextError = FirebaseAuthException(code: 'email-already-in-use');

      final states = await record(register);

      expect(states, [
        isA<AuthLoading>(),
        error('This email is already registered.'),
      ]);
      expect(firebase.documents, isEmpty);
      expect(cubit.currentUser, isNull);
    });

    test('reports a missing user', () async {
      firebase.createReturnsNoUser = true;

      final states = await record(register);

      expect(states.last, error('User creation failed'));
      expect(firebase.documents, isEmpty);
    });

    test(
      'a failed Firestore write is logged and does not fail sign-up',
      () async {
        firebase
          ..failOnCall = 'firestore.set'
          ..nextError = FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          );

        final states = await record(register);

        expect(states.last, isA<AuthSuccess>());
        expect(firebase.documents, isEmpty);
      },
    );

    test('an unexpected error is reported as its text', () async {
      firebase.nextError = StateError('boom');

      final states = await record(register);

      expect(states.last, error(StateError('boom').toString()));
    });
  });

  group('login', () {
    test('emits loading then success and trims both fields', () async {
      final states = await record(
        () => cubit.login(email: ' a@b.com ', password: ' secret '),
      );

      expect(states, [isA<AuthLoading>(), isA<AuthSuccess>()]);
      expect(firebase.calls, ['signIn|a@b.com|secret']);
    });

    test('shows the friendly message when auth fails', () async {
      firebase.nextError = FirebaseAuthException(code: 'invalid-credential');

      final states = await record(
        () => cubit.login(email: 'a@b.com', password: 'wrong'),
      );

      expect(states, [isA<AuthLoading>(), error('Invalid email or password.')]);
    });

    test('turns away an account whose email is not verified', () async {
      firebase.loginAccountVerified = false;

      final states = await record(
        () => cubit.login(email: 'a@b.com', password: 'secret'),
      );

      expect(states.last, error(AuthCubit.emailNotVerifiedMessage));
    });

    test('can be retried after a failure', () async {
      firebase.nextError = FirebaseAuthException(code: 'invalid-credential');
      await cubit.login(email: 'a@b.com', password: 'wrong');

      final states = await record(
        () => cubit.login(email: 'a@b.com', password: 'right'),
      );

      expect(states, [isA<AuthLoading>(), isA<AuthSuccess>()]);
    });
  });

  group('sendEmailVerification', () {
    test('emits the address the email went to', () async {
      await register();

      final states = await record(cubit.sendEmailVerification);

      expect(states, [
        isA<AuthLoading>(),
        isA<AuthVerificationEmailSent>().having(
          (s) => s.email,
          'email',
          'ada@b.com',
        ),
      ]);
    });

    test('asks the user to log in again when nobody is signed in', () async {
      final states = await record(cubit.sendEmailVerification);

      expect(states.last, error(AuthCubit.noUserMessage));
    });

    test('shows the friendly message on failure', () async {
      await register();
      firebase.nextError = FirebaseAuthException(
        code: 'network-request-failed',
      );

      final states = await record(cubit.sendEmailVerification);

      expect(states.last, error('No internet connection.'));
    });
  });

  group('checkEmailVerified', () {
    setUp(() async {
      await register();
    });

    test('reports a pending verification as an error', () async {
      final states = await record(cubit.checkEmailVerified);

      expect(states, [
        isA<AuthLoading>(),
        error(AuthCubit.verificationPendingMessage),
      ]);
    });

    test('emits verified once the user opened the link', () async {
      firebase.verifiedOnServer = true;

      final states = await record(cubit.checkEmailVerified);

      expect(states, [isA<AuthLoading>(), isA<AuthEmailVerified>()]);
      expect(cubit.currentUser?.emailVerified, isTrue);
    });

    test('can be retried after a pending check', () async {
      await cubit.checkEmailVerified();
      firebase.verifiedOnServer = true;

      final states = await record(cubit.checkEmailVerified);

      expect(states.last, isA<AuthEmailVerified>());
    });
  });

  group('sendPasswordReset', () {
    test('emits the trimmed email once the link is sent', () async {
      final states = await record(
        () => cubit.sendPasswordReset(email: ' a@b.com '),
      );

      expect(states, [
        isA<AuthLoading>(),
        isA<AuthPasswordResetSent>().having((s) => s.email, 'email', 'a@b.com'),
      ]);
      expect(firebase.calls, ['reset|a@b.com']);
    });
  });

  group('logout', () {
    test('signs out and emits logged out', () async {
      await cubit.login(email: 'a@b.com', password: 'secret');

      final states = await record(cubit.logout);

      expect(states, [isA<AuthLoading>(), isA<AuthLoggedOut>()]);
      expect(cubit.currentUser, isNull);
    });
  });

  group('firebaseErrorMessage', () {
    test('maps the codes from the session', () {
      expect(
        cubit.firebaseErrorMessage('weak-password'),
        'The password is too weak.',
      );
      expect(
        cubit.firebaseErrorMessage('email-already-in-use'),
        'This email is already registered.',
      );
      expect(
        cubit.firebaseErrorMessage('invalid-email'),
        'Invalid email address.',
      );
      expect(
        cubit.firebaseErrorMessage('user-not-found'),
        'No user found with this email.',
      );
      expect(cubit.firebaseErrorMessage('wrong-password'), 'Wrong password.');
      expect(
        cubit.firebaseErrorMessage('invalid-credential'),
        'Invalid email or password.',
      );
      expect(
        cubit.firebaseErrorMessage('network-request-failed'),
        'No internet connection.',
      );
      expect(
        cubit.firebaseErrorMessage('account-exists-with-different-credential'),
        'This email is already used with another login method.',
      );
    });

    test('never leaks raw Firebase text for unknown codes', () {
      expect(
        cubit.firebaseErrorMessage('some-new-code'),
        'Authentication failed. Please try again.',
      );
    });
  });
}
