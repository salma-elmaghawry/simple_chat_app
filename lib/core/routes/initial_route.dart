import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:simple_chat_app/core/routes/routes.dart';

/// Where the app opens, given the user Firebase restored from disk.
///
/// A signed-in user with an unverified email must not reach home. Creating an
/// account signs the user in, so without this check, closing the app right
/// after sign-up would skip verification on the next launch.
String initialRouteFor(User? user) {
  if (user == null) return Routes.intro;
  if (!user.emailVerified) return Routes.verifyEmail;
  return Routes.home;
}
