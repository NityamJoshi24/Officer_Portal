import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_navigator.dart';
import '../../../core/providers/api_providers.dart';
import '../../../core/providers/storage_providers.dart';
import '../../surveys/application/survey_providers.dart';
import '../presentation/login_screen.dart';
import 'auth_controller.dart';
import 'auth_state.dart';
import 'login_flow_controller.dart';
import 'login_flow_state.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.read(userPreferencesStorageProvider));
});

final loginFlowControllerProvider =
    StateNotifierProvider.autoDispose<LoginFlowController, LoginFlowState>((ref) {
  return LoginFlowController(ref);
});

final stateListProvider = FutureProvider<List<String>>((ref) async {
  final apiManager = ref.read(apiManagerProvider);
  final result = await apiManager.getStateList();
  if (!result.isSuccess) {
    throw Exception(result.error ?? 'Unable to load states');
  }
  return apiManager.parseStates(result.data);
});

class AuthSessionController {
  AuthSessionController(this._ref);

  final Ref _ref;
  bool _isHandlingUnauthorized = false;

  Future<void> logout() async {
    final user = _ref.read(authControllerProvider).currentUser;

    if (user != null) {
      final apiManager = _ref.read(apiManagerProvider);
      final result = await apiManager.logout(user.userToken, user.userId);
      if (result.isSuccess) {
        // ignore: avoid_print
        print('[Logout] API logout successful for userId: ${user.userId}');
      } else {
        // ignore: avoid_print
        print('[Logout] API logout failed: ${result.error}');
      }
    }

    await _ref.read(authControllerProvider.notifier).logout();
    await _ref.read(surveyFiltersProvider.notifier).clear();
    _ref.read(apiManagerProvider).api.clearAuthToken();
  }

  Future<void> handleUnauthorized() async {
    if (_isHandlingUnauthorized) {
      return;
    }

    _isHandlingUnauthorized = true;
    try {
      await _ref.read(authControllerProvider.notifier).logout();
      await _ref.read(surveyFiltersProvider.notifier).clear();
      _ref.read(apiManagerProvider).api.clearAuthToken();

      final navigator = appNavigatorKey.currentState;
      if (navigator != null) {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const LoginScreen(),
          ),
          (route) => false,
        );
      }
    } finally {
      _isHandlingUnauthorized = false;
    }
  }
}

final authSessionControllerProvider = Provider<AuthSessionController>((ref) {
  return AuthSessionController(ref);
});

final unauthorizedHandlerBindingProvider = Provider<void>((ref) {
  final apiServices = ref.read(apiManagerProvider).api;
  apiServices.setUnauthorizedHandler(() async {
    await ref.read(authSessionControllerProvider).handleUnauthorized();
  });

  ref.onDispose(() {
    apiServices.setUnauthorizedHandler(null);
  });
});
