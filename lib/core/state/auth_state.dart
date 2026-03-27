import '../../models/user_model.dart';

class AuthState {
  const AuthState({
    this.currentUser,
  });

  final UserModel? currentUser;

  bool get isLoggedIn => currentUser != null;

  AuthState copyWith({
    Object? currentUser = _sentinel,
  }) {
    return AuthState(
      currentUser: currentUser == _sentinel
          ? this.currentUser
          : currentUser as UserModel?,
    );
  }

  static const _sentinel = Object();
}