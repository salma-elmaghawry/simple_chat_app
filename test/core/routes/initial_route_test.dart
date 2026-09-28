import 'package:flutter_test/flutter_test.dart';
import 'package:simple_chat_app/core/routes/initial_route.dart';
import 'package:simple_chat_app/core/routes/routes.dart';

import '../../helpers/fake_firebase.dart';

void main() {
  test('nobody signed in starts on the intro', () {
    expect(initialRouteFor(null), Routes.intro);
  });

  test('a verified user skips straight to home', () {
    expect(initialRouteFor(FakeUser(emailVerified: true)), Routes.home);
  });

  test('an unverified user resumes on the verify screen, never home', () {
    expect(initialRouteFor(FakeUser(emailVerified: false)), Routes.verifyEmail);
  });
}
