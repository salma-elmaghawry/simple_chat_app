import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_chat_app/features/auth/data/models/user_model.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  // SharedPreferences can't store a UserModel, so we turn its JSON into a
  // String with jsonEncode before saving.
  static Future<void> saveUserModelData({
    required UserModel userModel,
    required String userKey,
  }) async {
    // to make sure the data is saved as a string, we convert the user model to JSON and then encode it to a string
    final String userJson = jsonEncode(userModel.toJson());

    await sharedPreferences.setString(userKey, userJson);
  }

  // And reverse it with jsonDecode when we read it back.
  static UserModel? getUserModelData({required String userKey}) {
    final String? userJson = sharedPreferences.getString(userKey);

    if (userJson == null) {
      return null;
    }
   // Convert the JSON string back to a Map<String, dynamic> and then create a UserModel from it
    final Map<String, dynamic> userMap = jsonDecode(userJson);

    return UserModel.fromJson(userMap);
  }

  static Future<bool> clearData() async {
    return await sharedPreferences.clear();
  }
}
