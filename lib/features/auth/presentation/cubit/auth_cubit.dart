import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  late final FirebaseAuth auth = FirebaseAuth.instance;

  // error message from firebase
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
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toJson(), SetOptions(merge: true));
    } catch (e) {
      log(e.toString());
    }
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
}
