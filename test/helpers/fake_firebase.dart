// Firestore's CollectionReference and DocumentReference are sealed, but a fake
// has to implement them to stand in for the real thing in tests.
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory Firebase Auth and Cloud Firestore, so nothing touches the
/// network. Every call is appended to [calls], in order, across both.
class FakeFirebase {
  FakeFirebase({User? user}) {
    auth = FakeFirebaseAuth(this, user);
    firestore = FakeFirestore(this);
    if (user is FakeUser) user.firebase = this;
  }

  late final FakeFirebaseAuth auth;
  late final FakeFirestore firestore;

  final List<String> calls = [];

  /// Documents written to Firestore, keyed by `collection/id`.
  final Map<String, Map<String, dynamic>> documents = {};
  final Map<String, SetOptions?> writeOptions = {};

  /// Thrown by the next matching call, then cleared.
  Object? nextError;

  /// When set, [nextError] waits for a call that starts with this text.
  String? failOnCall;

  /// Whether the account that signs in has a verified email.
  bool loginAccountVerified = true;

  /// What Firebase reports after the user reloads. Flip it to simulate the
  /// user opening the emailed link.
  bool verifiedOnServer = false;

  /// Makes account creation return no user.
  bool createReturnsNoUser = false;

  /// While set, calls wait on it. Lets a test see the in-flight state.
  Completer<void>? gate;

  Future<void> enter(String call) async {
    calls.add(call);
    await gate?.future;
    final error = nextError;
    if (error != null && (failOnCall == null || call.startsWith(failOnCall!))) {
      nextError = null;
      failOnCall = null;
      throw error;
    }
  }
}

class FakeUser extends Fake implements User {
  FakeUser({
    this.uid = 'uid-1',
    this.displayName,
    this.email,
    this.emailVerified = true,
  });

  @override
  final String uid;

  @override
  String? displayName;

  @override
  final String? email;

  @override
  bool emailVerified;

  FakeFirebase? firebase;

  @override
  Future<void> updateDisplayName(String? displayName) async {
    await firebase!.enter('updateDisplayName|$displayName');
    this.displayName = displayName;
  }

  @override
  Future<void> sendEmailVerification([
    ActionCodeSettings? actionCodeSettings,
  ]) => firebase!.enter('sendEmailVerification');

  @override
  Future<void> reload() async {
    await firebase!.enter('reload');
    if (firebase!.verifiedOnServer) emailVerified = true;
  }
}

class FakeUserCredential extends Fake implements UserCredential {
  FakeUserCredential(this.user);

  @override
  final User? user;
}

class FakeFirebaseAuth extends Fake implements FirebaseAuth {
  FakeFirebaseAuth(this._firebase, this._user);

  final FakeFirebase _firebase;
  User? _user;

  @override
  User? get currentUser => _user;

  @override
  Stream<User?> authStateChanges() => Stream.value(_user);

  FakeUser _signedIn({required String uid, required String email, bool? ok}) {
    return FakeUser(uid: uid, email: email, emailVerified: ok ?? false)
      ..firebase = _firebase;
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebase.enter('createUser|$email|$password');
    // Like Firebase: a new account is signed in but not verified.
    _user = _firebase.createReturnsNoUser
        ? null
        : _signedIn(uid: 'new-uid', email: email);
    return FakeUserCredential(_user);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebase.enter('signIn|$email|$password');
    _user = _signedIn(
      uid: 'uid-1',
      email: email,
      ok: _firebase.loginAccountVerified,
    );
    return FakeUserCredential(_user);
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) => _firebase.enter('reset|$email');

  @override
  Future<void> signOut() async {
    await _firebase.enter('signOut');
    _user = null;
  }
}

class FakeFirestore extends Fake implements FirebaseFirestore {
  FakeFirestore(this._firebase);

  final FakeFirebase _firebase;

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _FakeCollection(_firebase, path);
}

class _FakeCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _FakeCollection(this._firebase, this._path);

  final FakeFirebase _firebase;
  final String _path;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      _FakeDocument(_firebase, '$_path/$path');
}

class _FakeDocument extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _FakeDocument(this._firebase, this._path);

  final FakeFirebase _firebase;
  final String _path;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    await _firebase.enter('firestore.set|$_path');
    _firebase.documents[_path] = data;
    _firebase.writeOptions[_path] = options;
  }
}
