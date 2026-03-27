import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());

  void login(String username, {required String stateName}) {
    final displayName = username
        .split('.')
        .map((part) => part.isEmpty ? '' : part[0].toUpperCase() + part.substring(1))
        .join(' ');

    state = AuthState(
      currentUser: LoggedInUser(
        username: username,
        name: displayName,
      ),
      selectedState: stateName,
    );
  }

  void logout() {
    state = const AuthState();
  }
}
