class LoggedInUser {
  const LoggedInUser({
    required this.username,
    required this.name,
  });

  final String username;
  final String name;
}

class AuthState {
  const AuthState({
    this.currentUser,
    this.selectedState,
  });

  final LoggedInUser? currentUser;
  final String? selectedState;

  bool get isLoggedIn => currentUser != null;

  AuthState copyWith({
    Object? currentUser = _sentinel,
    Object? selectedState = _sentinel,
  }) {
    return AuthState(
      currentUser: currentUser == _sentinel
          ? this.currentUser
          : currentUser as LoggedInUser?,
      selectedState: selectedState == _sentinel
          ? this.selectedState
          : selectedState as String?,
    );
  }

  static const _sentinel = Object();
}
