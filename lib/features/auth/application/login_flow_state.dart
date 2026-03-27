import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/commons/app_enums.dart';

part 'login_flow_state.freezed.dart';

@freezed
class LoginFlowState with _$LoginFlowState {
  const LoginFlowState._();

  const factory LoginFlowState({
    @Default(LoginStep.mobilePassword) LoginStep step,
    @Default(false) bool isLoading,
    String? errorMessage,
    String? selectedState,
    String? userToken,
  }) = _LoginFlowState;
}
