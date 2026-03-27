import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/commons/app_enums.dart';
import '../../../core/providers/storage_providers.dart';
import '../../../core/state/survey_filters_controller.dart';
import '../../../core/state/survey_filters_state.dart';
import '../../../data/survey_dummy_data.dart';
import '../../../models/survey_model.dart';

final surveyFiltersProvider =
    StateNotifierProvider<SurveyFiltersController, SurveyFiltersState>((ref) {
  return SurveyFiltersController(ref.read(filterPreferencesStorageProvider));
});

final allSurveysProvider = Provider<List<SurveyModel>>((ref) {
  return dummySurveys;
});

final filteredSurveysProvider = Provider<List<SurveyModel>>((ref) {
  final surveys = ref.watch(allSurveysProvider);
  final filters = ref.watch(surveyFiltersProvider);

  return surveys.where((survey) {
    if (filters.season != null && !_isSurveyInSeason(survey.surveyDate, filters.season!)) {
      return false;
    }
    if (filters.village != null &&
        survey.village.toLowerCase() != filters.village!.toLowerCase()) {
      return false;
    }
    if (filters.taluka != null &&
        survey.taluka.toLowerCase() != filters.taluka!.toLowerCase()) {
      return false;
    }
    if (filters.statuses != null &&
        filters.statuses!.isNotEmpty &&
        !filters.statuses!.contains(survey.status)) {
      return false;
    }
    if (filters.dateRange != null) {
      final surveyDate = survey.surveyDate;
      if (surveyDate.isBefore(filters.dateRange!.start) ||
          surveyDate.isAfter(filters.dateRange!.end)) {
        return false;
      }
    }
    return true;
  }).toList();
});

final pendingSurveyCountProvider = Provider<int>((ref) {
  return ref
      .watch(filteredSurveysProvider)
      .where((survey) => survey.status == SurveyStatus.pending)
      .length;
});

final approvedSurveyCountProvider = Provider<int>((ref) {
  return ref
      .watch(filteredSurveysProvider)
      .where((survey) => survey.status == SurveyStatus.approved)
      .length;
});

final rejectedSurveyCountProvider = Provider<int>((ref) {
  return ref
      .watch(filteredSurveysProvider)
      .where((survey) => survey.status == SurveyStatus.rejected)
      .length;
});

bool _isSurveyInSeason(DateTime date, String season) {
  final month = date.month;
  switch (season.toLowerCase()) {
    case 'kharif':
      return month >= 6 && month <= 10;
    case 'rabi':
      return month >= 11 || month <= 3;
    case 'zaid':
      return month >= 4 && month <= 6;
    default:
      return true;
  }
}
