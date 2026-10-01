import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:simple_chat_app/core/helpers/cache_helper.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  late final FirebaseAuth auth = FirebaseAuth.instance;

  String firebaseErrorMessage(String message) {
    switch (message) {
      case 'weak-password':
        return 'The password is too weak it must be at least 6 characters.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'account-exists-with-different-credential':
        return 'This email is already used with another login method.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  Future<void> saveUserData(UserModel userModel) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel.uid)
        .set(userModel.toJson(), SetOptions(merge: true));
  }

  Future<void> registerWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      final UserCredential credential = await auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = credential.user;

      if (user == null) {
        emit(AuthError(message: 'User creation failed'));
        return;
      }

      await user.updateDisplayName(fullName.trim());
      await user.sendEmailVerification();

      final UserModel userModel = UserModel(
        email: email,
        password: password,
        name: fullName,
        uid: user.uid,
      );

      await saveUserData(userModel);
      emit(AuthSuccess(user: user));
    } on FirebaseException catch (e) {
      emit(AuthError(message: firebaseErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      final UserCredential credential = await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? loggedInUser = credential.user;

      if (loggedInUser == null) {
        emit(AuthError(message: 'Login failed. Please try again.'));
        return;
      }

      await loggedInUser.reload();

      final User? currentUser = auth.currentUser;

      if (currentUser == null) {
        emit(AuthError(message: 'User not found. Please try again.'));
        return;
      }

      if (!currentUser.emailVerified) {
        emit(AuthEmailNotVerified(user: currentUser));
        return;
      }

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        emit(AuthError(message: 'User data not found.'));
        return;
      }

      final UserModel userModel = UserModel.fromJson(
        userDoc.data() as Map<String, dynamic>,
      );

      await CacheHelper.saveUserModelData(
        userKey: "user",
        userModel: userModel,
      );

      emit(AuthSuccess(user: currentUser));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: firebaseErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError(message: 'Something went wrong. Please try again.'));
    }
  }

  bool isGoogleSignInInitialized = false;
  Future<void> initializeGoogleSignIn() async {
    if (isGoogleSignInInitialized) return;

    await GoogleSignIn.instance.initialize();

    isGoogleSignInInitialized = true;
  }

  Future<UserModel> getOrCreateGoogleUser(User user) async {
    final DocumentReference userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    final DocumentSnapshot userDoc = await userRef.get();

    if (userDoc.exists) {
      return UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    }

    final UserModel userModel = UserModel(
      email: user.email ?? '',
      password: '',
      name: user.displayName ?? '',
      image: user.photoURL,
      uid: user.uid,
    );

    await userRef.set(userModel.toJson());

    return userModel;
  }

  Future<void> loginWithGoogle() async {
    try {
      emit(AuthLoading());

      await initializeGoogleSignIn();

      final GoogleSignInAccount googleUser = await GoogleSignIn.instance
          .authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential googleCredential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await auth.signInWithCredential(
        googleCredential,
      );

      final User? user = userCredential.user;

      if (user == null) {
        emit(AuthError(message: 'Google login failed. Please try again.'));
        return;
      }

      final UserModel userModel = await getOrCreateGoogleUser(user);

      await CacheHelper.saveUserModelData(
        userKey: "user",
        userModel: userModel,
      );

      emit(AuthSuccess(user: user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: firebaseErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError(message: 'Google login failed. Please try again.'));
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      emit(AuthLoading());

      await auth.sendPasswordResetEmail(email: email.trim());

      emit(AuthPasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: firebaseErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError(message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> signOut() async {
    try {
      emit(AuthLoading());

      await GoogleSignIn.instance.signOut();

      await auth.signOut();

      await CacheHelper.clearData();

      emit(AuthInitial());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: firebaseErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError(message: 'Sign out failed. Please try again.'));
    }
  }
}
