import 'package:flutter_test/flutter_test.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';

void main() {
  test('toJson writes the four profile fields, image null at sign-up', () {
    final json = UserModel(
      email: 'a@b.com',
      name: 'Ada',
      uid: 'u1',
      password: 'secret1',
    ).toJson();

    expect(json, {
      'email': 'a@b.com',
      'name': 'Ada',
      'image': null,
      'uid': 'u1',
    });
  });

  test('never carries a password', () {
    final json = UserModel(
      email: 'a@b.com',
      name: 'Ada',
      uid: 'u1',
      password: 'secret1',
    ).toJson();

    expect(json.containsKey('password'), isFalse);
  });

  test('fromJson reads what toJson wrote', () {
    final original = UserModel(
      email: 'a@b.com',
      name: 'Ada',
      uid: 'u1',
      password: 'secret1',
      image: 'https://example.com/ada.png',
    );

    final copy = UserModel.fromJson(original.toJson());

    expect(copy.email, 'a@b.com');
    expect(copy.name, 'Ada');
    expect(copy.uid, 'u1');
    expect(copy.image, 'https://example.com/ada.png');
  });
}
