import 'package:flutter/material.dart';

import '../../models/filter_preferences_entity.dart';
import '../../models/survey_model.dart';

class SurveyFiltersState {
  const SurveyFiltersState({
    this.year,
    this.season,
    this.district,
    this.taluka,
    this.village,
    this.dateRange,
    this.statuses,
  });

  final String? year;
  final String? season;
  final String? district;
  final String? taluka;
  final String? village;
  final DateTimeRange? dateRange;
  final List<SurveyStatus>? statuses;

  bool get hasAny =>
      year != null ||
      season != null ||
      district != null ||
      taluka != null ||
      village != null ||
      dateRange != null ||
      (statuses != null && statuses!.isNotEmpty);

  SurveyFiltersState copyWith({
    Object? year = _sentinel,
    Object? season = _sentinel,
    Object? district = _sentinel,
    Object? taluka = _sentinel,
    Object? village = _sentinel,
    Object? dateRange = _sentinel,
    Object? statuses = _sentinel,
  }) {
    return SurveyFiltersState(
      year: year == _sentinel ? this.year : year as String?,
      season: season == _sentinel ? this.season : season as String?,
      district: district == _sentinel ? this.district : district as String?,
      taluka: taluka == _sentinel ? this.taluka : taluka as String?,
      village: village == _sentinel ? this.village : village as String?,
      dateRange: dateRange == _sentinel ? this.dateRange : dateRange as DateTimeRange?,
      statuses: statuses == _sentinel ? this.statuses : statuses as List<SurveyStatus>?,
    );
  }

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

  static const _sentinel = Object();
}
