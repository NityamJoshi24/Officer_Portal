import 'dart:convert';

import 'package:dcs_supervisor/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesStorage {
  UserPreferencesStorage._();
  static final instance = UserPreferencesStorage._();

  static const _key = 'logged_in_user';

  late SharedPreferences _prefs;

  static Future<void> init() async {
    instance._prefs = await SharedPreferences.getInstance();
  }

  UserModel? getUser() {
    final raw = _prefs.getString(_key);
    if(raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_key, jsonEncode(user.toJson()));
  }

  Future<void> clearUser() async {
    await _prefs.remove(_key);
  }
}