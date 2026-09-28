import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:simple_chat_app/app.dart';
import 'package:simple_chat_app/core/routes/initial_route.dart';
import 'package:simple_chat_app/core/routes/routes.dart';
import 'package:simple_chat_app/features/auth/presentation/cubit/auth_cubit.dart';

import '../../helpers/fake_firebase.dart';

void main() {
  Future<void> pumpApp(
    WidgetTester tester,
    FakeFirebase firebase, {
    String initialRoute = Routes.intro,
  }) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      SimpleChatApp(
        auth: firebase.auth,
        firestore: firebase.firestore,
        initialRoute: initialRoute,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> goToLogin(WidgetTester tester) async {
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();
  }

  Future<void> fillLogin(
    WidgetTester tester, {
    String email = 'a@b.com',
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), 'secret1');
  }

  Future<void> tapLogin(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pumpAndSettle();
  }

  Future<void> fillSignUp(WidgetTester tester) async {
    await tester.enterText(find.byType(TextFormField).at(0), 'Ada');
    await tester.enterText(find.byType(TextFormField).at(1), 'ada@b.com');
    await tester.enterText(find.byType(TextFormField).at(2), 'secret1');
  }

  Future<void> tapSignUp(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
    await tester.pumpAndSettle();
  }

  Future<void> goToSignUp(WidgetTester tester) async {
    await goToLogin(tester);
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
  }

  bool canPop(WidgetTester tester) =>
      tester.state<NavigatorState>(find.byType(Navigator)).canPop();

  Color? snackBarColor(WidgetTester tester) =>
      tester.widget<SnackBar>(find.byType(SnackBar)).backgroundColor;

  const signUpSuccess =
      'Sign Up Successfully please go to your email to verify your account!!';

  group('sign up', () {
    testWidgets('creates the account, saves the profile, then opens login', (
      tester,
    ) async {
      final firebase = FakeFirebase();
      await pumpApp(tester, firebase);
      await goToSignUp(tester);

      await fillSignUp(tester);
      await tapSignUp(tester);

      expect(firebase.calls, [
        'createUser|ada@b.com|secret1',
        'updateDisplayName|Ada',
        'sendEmailVerification',
        'firestore.set|users/new-uid',
      ]);
      expect(firebase.documents['users/new-uid'], {
        'email': 'ada@b.com',
        'name': 'Ada',
        'image': null,
        'uid': 'new-uid',
      });
      expect(find.text('Hello, Welcome Back'), findsOneWidget);
      expect(find.text('Hello, Let’s Get Started'), findsNothing);
      // Registering must not let the user into the app.
      expect(find.text('Welcome, Ada'), findsNothing);
    });

    testWidgets('confirms with a green snackbar', (tester) async {
      final firebase = FakeFirebase();
      await pumpApp(tester, firebase);
      await goToSignUp(tester);

      await fillSignUp(tester);
      await tapSignUp(tester);

      expect(find.text(signUpSuccess), findsOneWidget);
      expect(snackBarColor(tester), Colors.green);
    });

    testWidgets('shows a red snackbar when the email is taken', (tester) async {
      final firebase = FakeFirebase()
        ..nextError = FirebaseAuthException(code: 'email-already-in-use');
      await pumpApp(tester, firebase);
      await goToSignUp(tester);

      await fillSignUp(tester);
      await tapSignUp(tester);

      expect(find.text('This email is already registered.'), findsOneWidget);
      expect(snackBarColor(tester), Colors.red);
      expect(find.text('Hello, Let’s Get Started'), findsOneWidget);
    });

    testWidgets('covers the screen with a loading overlay while it works', (
      tester,
    ) async {
      final firebase = FakeFirebase()..gate = Completer<void>();
      await pumpApp(tester, firebase);
      await goToSignUp(tester);
      await fillSignUp(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      final hud = tester.widget<ModalProgressHUD>(
        find.byType(ModalProgressHUD),
      );
      expect(hud.inAsyncCall, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      firebase.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Hello, Welcome Back'), findsOneWidget);
    });

    testWidgets('invalid input never reaches Firebase', (tester) async {
      final firebase = FakeFirebase();
      await pumpApp(tester, firebase);
      await goToSignUp(tester);

      await tapSignUp(tester);

      expect(find.text('Email is required'), findsOneWidget);
      expect(firebase.calls, isEmpty);
    });
  });

  group('login', () {
    testWidgets('success opens home and clears the back stack', (tester) async {
      final firebase = FakeFirebase();
      await pumpApp(tester, firebase);
      await goToLogin(tester);

      await fillLogin(tester);
      await tapLogin(tester);

      expect(firebase.calls, ['signIn|a@b.com|secret1']);
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('a@b.com'), findsOneWidget);
      expect(canPop(tester), isFalse);
    });

    testWidgets('failure shows the message and stays on login', (tester) async {
      final firebase = FakeFirebase()
        ..nextError = FirebaseAuthException(code: 'invalid-credential');
      await pumpApp(tester, firebase);
      await goToLogin(tester);

      await fillLogin(tester);
      await tapLogin(tester);

      expect(find.text('Invalid email or password.'), findsOneWidget);
      expect(find.text('Hello, Welcome Back'), findsOneWidget);
      expect(find.text('Welcome'), findsNothing);
    });

    testWidgets('an unverified email is turned away before home', (
      tester,
    ) async {
      final firebase = FakeFirebase()..loginAccountVerified = false;
      await pumpApp(tester, firebase);
      await goToLogin(tester);

      await fillLogin(tester);
      await tapLogin(tester);

      expect(find.text(AuthCubit.emailNotVerifiedMessage), findsOneWidget);
      expect(find.text('Hello, Welcome Back'), findsOneWidget);
      expect(find.text('Welcome'), findsNothing);
    });

    testWidgets('invalid input never reaches Firebase', (tester) async {
      final firebase = FakeFirebase();
      await pumpApp(tester, firebase);
      await goToLogin(tester);

      await fillLogin(tester, email: 'not-an-email');
      await tapLogin(tester);

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(firebase.calls, isEmpty);
    });

    testWidgets('shows a spinner and disables the button while signing in', (
      tester,
    ) async {
      final firebase = FakeFirebase()..gate = Completer<void>();
      await pumpApp(tester, firebase);
      await goToLogin(tester);
      await fillLogin(tester);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      firebase.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Welcome'), findsOneWidget);
    });
  });

  group('forgot password', () {
    testWidgets('asks for a valid email first', (tester) async {
      final firebase = FakeFirebase();
      await pumpApp(tester, firebase);
      await goToLogin(tester);

      await tester.tap(find.text('Forgot Password'));
      await tester.pumpAndSettle();

      expect(
        find.text('Enter a valid email address above to reset your password.'),
        findsOneWidget,
      );
      expect(firebase.calls, isEmpty);
    });

    testWidgets('sends the reset link and confirms it', (tester) async {
      final firebase = FakeFirebase();
      await pumpApp(tester, firebase);
      await goToLogin(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
      await tester.tap(find.text('Forgot Password'));
      await tester.pumpAndSettle();

      expect(firebase.calls, ['reset|a@b.com']);
      expect(find.text('Password reset link sent to a@b.com.'), findsOneWidget);
    });
  });

  group('verify email', () {
    FakeFirebase unverified() =>
        FakeFirebase(user: FakeUser(email: 'ada@b.com', emailVerified: false));

    testWidgets('tells the user to check their inbox', (tester) async {
      await pumpApp(tester, unverified(), initialRoute: Routes.verifyEmail);

      expect(find.text('Check Your Email'), findsOneWidget);
      expect(find.textContaining('ada@b.com'), findsOneWidget);
      expect(find.text("I've Verified My Email"), findsOneWidget);
      expect(find.text('Resend Email'), findsOneWidget);
    });

    testWidgets('stays put with a hint until the link is opened', (
      tester,
    ) async {
      final firebase = unverified();
      await pumpApp(tester, firebase, initialRoute: Routes.verifyEmail);

      await tester.tap(find.text("I've Verified My Email"));
      await tester.pumpAndSettle();

      expect(firebase.calls, ['reload']);
      expect(find.text(AuthCubit.verificationPendingMessage), findsOneWidget);
      expect(find.text('Check Your Email'), findsOneWidget);
    });

    testWidgets('moves on to login once verified', (tester) async {
      final firebase = unverified()..verifiedOnServer = true;
      await pumpApp(tester, firebase, initialRoute: Routes.verifyEmail);

      await tester.tap(find.text("I've Verified My Email"));
      await tester.pumpAndSettle();

      expect(find.text('Hello, Welcome Back'), findsOneWidget);
      expect(find.text('Email verified. Please log in.'), findsOneWidget);
      expect(canPop(tester), isFalse);
    });

    testWidgets('resend sends another email and confirms it', (tester) async {
      final firebase = unverified();
      await pumpApp(tester, firebase, initialRoute: Routes.verifyEmail);

      await tester.tap(find.text('Resend Email'));
      await tester.pumpAndSettle();

      expect(firebase.calls, ['sendEmailVerification']);
      expect(
        find.text('Verification email sent to ada@b.com.'),
        findsOneWidget,
      );
      expect(find.text('Check Your Email'), findsOneWidget);
    });

    testWidgets('a failed resend shows the error', (tester) async {
      final firebase = unverified()
        ..nextError = FirebaseAuthException(code: 'network-request-failed');
      await pumpApp(tester, firebase, initialRoute: Routes.verifyEmail);

      await tester.tap(find.text('Resend Email'));
      await tester.pumpAndSettle();

      expect(find.text('No internet connection.'), findsOneWidget);
    });
  });

  testWidgets('full flow: sign up, verify, log in, land on home', (
    tester,
  ) async {
    final firebase = FakeFirebase();
    await pumpApp(tester, firebase);
    await goToSignUp(tester);

    await fillSignUp(tester);
    await tapSignUp(tester);
    expect(find.text('Hello, Welcome Back'), findsOneWidget);

    // The user opens the link in their inbox, then logs in.
    firebase.loginAccountVerified = true;
    await fillLogin(tester, email: 'ada@b.com');
    await tapLogin(tester);

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('ada@b.com'), findsOneWidget);
    expect(canPop(tester), isFalse);
  });

  group('session', () {
    testWidgets('a signed-in start opens home with nothing behind it', (
      tester,
    ) async {
      final firebase = FakeFirebase(
        user: FakeUser(displayName: 'Salma', email: 's@b.com'),
      );
      await pumpApp(tester, firebase, initialRoute: Routes.home);

      expect(find.text('Welcome, Salma'), findsOneWidget);
      expect(find.text('s@b.com'), findsOneWidget);
      expect(find.text('Get Closer To EveryOne'), findsNothing);
      expect(canPop(tester), isFalse);
    });

    testWidgets('an unverified user restarts on verify, not home', (
      tester,
    ) async {
      final firebase = FakeFirebase(
        user: FakeUser(email: 'ada@b.com', emailVerified: false),
      );
      await pumpApp(
        tester,
        firebase,
        initialRoute: initialRouteFor(firebase.auth.currentUser),
      );

      expect(find.text('Check Your Email'), findsOneWidget);
      expect(find.text('Welcome'), findsNothing);
      expect(canPop(tester), isFalse);
    });

    testWidgets('logout returns to login and clears the back stack', (
      tester,
    ) async {
      final firebase = FakeFirebase(user: FakeUser(email: 's@b.com'));
      await pumpApp(tester, firebase, initialRoute: Routes.home);

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(firebase.calls, ['signOut']);
      expect(firebase.auth.currentUser, isNull);
      expect(find.text('Hello, Welcome Back'), findsOneWidget);
      expect(find.text('Welcome'), findsNothing);
      expect(canPop(tester), isFalse);
    });
  });
}
