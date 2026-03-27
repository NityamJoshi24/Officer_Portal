import 'package:dcs_supervisor/core/user_preferences_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_model.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._storage) : super(AuthState(currentUser: _storage.getUser()));

  final UserPreferencesStorage _storage;

  Future<void> login(UserModel user) async {
    await _storage.saveUser(user);
    state = AuthState(currentUser: user);
  }

  Future<void> logout() async {
    await _storage.clearUser();
    state = const AuthState();
  }
}