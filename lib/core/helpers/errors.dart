// error message from firebase
String firebaseErrorMessage(String code) {
  switch (code) {
    case 'weak-password':
      return 'The password is too weak.';
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
