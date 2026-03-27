import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api/api_manager.dart';
import 'filter_preferences_storage.dart';
import 'state/auth_controller.dart';
import 'state/auth_state.dart';
import 'state/survey_filters_controller.dart';
import 'state/survey_filters_state.dart';

final apiManagerProvider = Provider<ApiManager>((ref) {
  return ApiManager();
});

final filterPreferencesStorageProvider = Provider<FilterPreferencesStorage>((ref) {
  return FilterPreferencesStorage.instance;
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});

final surveyFiltersProvider =
    StateNotifierProvider<SurveyFiltersController, SurveyFiltersState>((ref) {
  return SurveyFiltersController(ref.read(filterPreferencesStorageProvider));
});

final stateListProvider = FutureProvider<List<String>>((ref) async {
  final apiManager = ref.read(apiManagerProvider);
  final result = await apiManager.getStateList();
  if (!result.isSuccess) {
    throw Exception(result.error ?? 'Unable to load states');
  }
  return apiManager.parseStates(result.data);
});
