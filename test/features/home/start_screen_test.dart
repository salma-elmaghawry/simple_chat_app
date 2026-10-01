import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_chat_app/app.dart';
import 'package:simple_chat_app/core/helpers/cache_helper.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';

import '../../helpers/fake_firebase.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await CacheHelper.init();
  });

  Future<void> pumpApp(WidgetTester tester, FakeUser? user) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(SimpleChatApp(auth: FakeFirebase(user: user).auth));
    await tester.pumpAndSettle();
  }

  testWidgets('no signed-in user starts on intro', (tester) async {
    await pumpApp(tester, null);
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('a signed-in user with an unverified email starts on intro', (
    tester,
  ) async {
    await pumpApp(tester, FakeUser(emailVerified: false));
    expect(find.text('Get Started'), findsOneWidget);
  });

  testWidgets('a verified user starts on home and sees cached profile data', (
    tester,
  ) async {
    await CacheHelper.saveUserModelData(
      userKey: 'user',
      userModel: UserModel(
        email: 'ada@example.com',
        name: 'Ada Lovelace',
        uid: 'uid-1',
        password: '',
      ),
    );

    await pumpApp(tester, FakeUser());
    expect(find.text('Easy Chat'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(find.text('ada@example.com'), findsOneWidget);
    expect(find.text('Edit Your Profile'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });

  test('CacheHelper saves and reads back a UserModel', () async {
    await CacheHelper.saveUserModelData(
      userKey: 'user',
      userModel: UserModel(
        email: 'a@b.com',
        name: 'Ada',
        uid: 'u1',
        password: '',
        image: 'https://example.com/a.png',
      ),
    );

    final user = CacheHelper.getUserModelData(userKey: 'user');
    expect(user?.name, 'Ada');
    expect(user?.image, 'https://example.com/a.png');

    await CacheHelper.clearData();
    expect(CacheHelper.getUserModelData(userKey: 'user'), isNull);
  });
}
