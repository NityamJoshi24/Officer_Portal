import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/commons/app_enums.dart';
import '../../../core/providers.dart';
import 'login_flow_state.dart';

class LoginFlowController extends StateNotifier<LoginFlowState> {
  LoginFlowController(this._ref) : super(const LoginFlowState());

  final Ref _ref;

  void selectState(String stateName) {
    state = state.copyWith(selectedState: stateName, errorMessage: null);
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }
    state = state.copyWith(errorMessage: null);
  }

  void goBackToCredentials() {
    state = state.copyWith(
      step: LoginStep.mobilePassword,
      errorMessage: null,
    );
  }

  Future<bool> verifyCredentials({
    required String mobile,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final apiManager = _ref.read(apiManagerProvider);
      final result = await apiManager.verifyCredentials(mobile, password);

      if (!result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? 'Invalid credentials',
        );
        return false;
      }

      final token = apiManager.extractSessionToken(result.data);
      state = state.copyWith(
        step: LoginStep.otp,
        isLoading: false,
        userToken: token,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> verifyOtp({
    required String mobile,
    required String password,
    required String otp,
  }) async {
    if (otp.length < 6) {
      state = state.copyWith(errorMessage: 'Please enter all 6 digits.');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final apiManager = _ref.read(apiManagerProvider);
      final result = await apiManager.mobileLogin(
        token: state.userToken,
        otp: otp,
        password: password,
        mobile: mobile,
      );

      if (!result.isSuccess) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.error ?? 'OTP verification failed',
        );
        return false;
      }

      final data = result.data;
      final isVerified = apiManager.isOtpVerified(data);
      if (!isVerified) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: apiManager.extractMessage(data) ?? 'Invalid OTP',
        );
        return false;
      }

      final user = apiManager.parseUser(data);
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to read user data. Please try again.',
        );
        return false;
      }

      apiManager.api.setAuthToken(user.userToken);
      await _ref.read(authControllerProvider.notifier).login(user);
      state = state.copyWith(isLoading: false, errorMessage: null);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}
