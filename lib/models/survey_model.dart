// ─────────────────────────────────────────────────────────────────────────────
// Survey data models
// ─────────────────────────────────────────────────────────────────────────────

import '../core/commons/app_enums.dart';

class SurveyImage {
  final String landUsage;
  final String cropAreaType;
  final double area;
  final String areaUnit;
  final int colorHex;
  final String? cropSowingDate;
  final String? cropStatus;
  final String? cropClassName;
  final String? irrigationSource;
  final String? remarks;

  const SurveyImage({
    required this.landUsage,
    required this.cropAreaType,
    required this.area,
    required this.areaUnit,
    required this.colorHex,
    required this.cropClassName,
    required this.cropSowingDate,
    required this.cropStatus,
    required this.irrigationSource,
    required this.remarks,
  });
}

class SurveyModel {
  final String id;
  final int sequenceNumber;
  final int totalSequence;
  final String ownerName;
  final String taluka;
  final String village;
  final String surveyNo;
  final String farmlandPlotId;
  final double farmerTotalArea;
  final String surveyorName;
  final DateTime farmAllocation;
  final DateTime surveyDate;
  final DateTime submissionDate;
  final double latitude;
  final double longitude;
  final List<SurveyImage> reviewedImages;
  final String mapCoordinateLabel;
  SurveyStatus status;

  SurveyModel({
    required this.id,
    required this.sequenceNumber,
    required this.totalSequence,
    required this.ownerName,
    required this.taluka,
    required this.village,
    required this.surveyNo,
    required this.farmlandPlotId,
    required this.farmerTotalArea,
    required this.surveyorName,
    required this.farmAllocation,
    required this.surveyDate,
    required this.submissionDate,
    required this.latitude,
    required this.longitude,
    required this.reviewedImages,
    required this.mapCoordinateLabel,
    this.status = SurveyStatus.pending,
  });
}
