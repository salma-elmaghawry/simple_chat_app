import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User?> register({required UserModel userModel}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: userModel.email,
      password: userModel.password,
    );
    final user = credential.user;
    if (user == null) return null;

    await user.updateDisplayName(userModel.name);
    await user.sendEmailVerification();
    await saveUserData(
      UserModel(
        email: userModel.email,
        name: userModel.name,
        uid: user.uid,
        password: userModel.password,
        image: userModel.image,
      ),
    );
    return user;
  }

  Future<User?> login({required UserModel userModel}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: userModel.email,
      password: userModel.password,
    );
    return credential.user;
  }

  Future<void> saveUserData(UserModel userModel) async {
    try {
      await _firestore
          .collection('users')
          .doc(userModel.uid)
          .set(userModel.toJson(), SetOptions(merge: true));
    } catch (e) {
      log('Failed to save user data: $e');
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.sendEmailVerification();
  }

  Future<void> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> sendPasswordReset({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
