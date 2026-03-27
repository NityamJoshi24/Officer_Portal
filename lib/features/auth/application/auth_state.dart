import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../models/user_model.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    UserModel? currentUser,
  }) = _AuthState;

  bool get isLoggedIn => currentUser != null;
}
