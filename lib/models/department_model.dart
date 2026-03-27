class DepartmentModel {
  final int departmentId;
  final String departmentName;
  final int departmentType;
  final String departmentCode;
  final bool isActive;
  final bool isDeleted;
  final DateTime? createdOn;
  final String? createdBy;
  final DateTime? modifiedOn;
  final String? modifiedBy;

  const DepartmentModel({
    required this.departmentId,
    required this.departmentName,
    required this.departmentType,
    required this.departmentCode,
    required this.isActive,
    required this.isDeleted,
    this.createdOn,
    this.createdBy,
    this.modifiedOn,
    this.modifiedBy,
});

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
        departmentId: json['departmentId'] as int,
        departmentName: json['departmentName'] as String? ?? '',
        departmentType: json['departmentType'] as int ?? 0,
        departmentCode: json['departmentCode'] as String? ?? '',
        isActive: json['isActive'] as bool ?? true,
        isDeleted: json['isDeleted'] as bool ?? false,
      createdOn: json['createdOn'] == null
        ? null
          : DateTime.tryParse(json['createdOn'] as String),
      createdBy: json['createdBy'] as String?,
      modifiedOn: json['modifiedOn'] == null
        ? null
          : DateTime.tryParse(json['modifiedOn'] as String),
      modifiedBy: json['modifiedBy'] as String?,
    );
  }

  Map<String,dynamic> toJson() {
    return {
      'departmentId': departmentId,
      'departmentName': departmentName,
      'departmentType': departmentType,
      'departmentCode': departmentCode,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'createdOn': createdOn?.toIso8601String(),
      'createdBy': createdBy,
      'modifiedOn': modifiedOn?.toIso8601String(),
      'modifiedBy': modifiedBy,
    };
  }
}