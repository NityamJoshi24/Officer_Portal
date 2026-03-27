import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../commons/app_enums.dart';
import '../../models/filter_preferences_entity.dart';
import '../../models/survey_model.dart';

part 'survey_filters_state.freezed.dart';

@freezed
class SurveyFiltersState with _$SurveyFiltersState {
  const SurveyFiltersState._();

  const factory SurveyFiltersState({
    String? year,
    String? season,
    String? district,
    String? taluka,
    String? village,
    DateTimeRange? dateRange,
    List<SurveyStatus>? statuses,
  }) = _SurveyFiltersState;

  bool get hasAny =>
      year != null ||
      season != null ||
      district != null ||
      taluka != null ||
      village != null ||
      dateRange != null ||
      (statuses != null && statuses!.isNotEmpty);

  FilterPreferencesEntity toEntity() {
    return FilterPreferencesEntity(
      id: 1,
      year: year,
      season: season,
      district: district,
      taluka: taluka,
      village: village,
      dateRangeStartMillis: dateRange?.start.millisecondsSinceEpoch,
      dateRangeEndMillis: dateRange?.end.millisecondsSinceEpoch,
      statusesCsv: (statuses ?? []).map((status) => status.name).join(','),
    );
  }

  factory SurveyFiltersState.fromEntity(FilterPreferencesEntity entity) {
    DateTimeRange? range;
    if (entity.dateRangeStartMillis != null && entity.dateRangeEndMillis != null) {
      range = DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(entity.dateRangeStartMillis!),
        end: DateTime.fromMillisecondsSinceEpoch(entity.dateRangeEndMillis!),
      );
    }

    List<SurveyStatus>? parsedStatuses;
    if (entity.statusesCsv.isNotEmpty) {
      final matches = entity.statusesCsv
          .split(',')
          .map(_surveyStatusFromName)
          .whereType<SurveyStatus>()
          .toList();
      if (matches.isNotEmpty) {
        parsedStatuses = matches;
      }
    }

    return SurveyFiltersState(
      year: entity.year,
      season: entity.season,
      district: entity.district,
      taluka: entity.taluka,
      village: entity.village,
      dateRange: range,
      statuses: parsedStatuses,
    );
  }

  static SurveyStatus? _surveyStatusFromName(String name) {
    for (final status in SurveyStatus.values) {
      if (status.name == name) {
        return status;
      }
    }
    return null;
  }
}
