import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../filter_preferences_storage.dart';
import 'survey_filters_state.dart';

class SurveyFiltersController extends StateNotifier<SurveyFiltersState> {
  SurveyFiltersController(this._storage)
      : super(
          _storage.getFilterPreferences() == null
              ? const SurveyFiltersState()
              : SurveyFiltersState.fromEntity(_storage.getFilterPreferences()!),
        );

  final FilterPreferencesStorage _storage;

  Future<void> update(SurveyFiltersState nextState) async {
    state = nextState;
    await _persist();
  }

  Future<void> clear() async {
    state = const SurveyFiltersState();
    await _storage.clearFilterPreferences();
  }

  Future<void> _persist() async {
    if (!state.hasAny) {
      await _storage.clearFilterPreferences();
      return;
    }
    await _storage.saveFilterPreferences(state.toEntity());
  }
}
