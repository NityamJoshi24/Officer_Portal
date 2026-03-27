import 'package:dcs_supervisor/models/department_model.dart';

class UserModel {
  final int userId;
  final String userName;
  final String userToken;
  final String userFirstName;
  final String userLastName;
  final String userFullName;
  final String userType;
  final String userMobileNumber;
  final String userEmailAddress;
  final int roleId;
  final String roleName;
  final int userStateLGDCode;
  final int userDistrictLGDCode;
  final bool isEmailVerified;
  final bool isMobileVerified;
  final bool isPasswordChanged;
  final bool isActive;
  final String territoryLevel;
  final DepartmentModel department;
  final String? stateName;
  final String? districtName;
  final DateTime? lastPasswordChangedDate;

  UserModel({
    required this.userId,
    required this.userName,
    required this.userToken,
    required this.userFirstName,
    required this.userLastName,
    required this.userFullName,
    required this.userType,
    required this.userMobileNumber,
    required this.userEmailAddress,
    required this.roleId,
    required this.roleName,
    required this.userStateLGDCode,
    required this.userDistrictLGDCode,
    required this.isEmailVerified,
    required this.isMobileVerified,
    required this.isPasswordChanged,
    required this.isActive,
    required this.territoryLevel,
    required this.department,
    this.stateName,
    this.districtName,
    this.lastPasswordChangedDate,
});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json;

    return UserModel(
      userId: data['userId'] as int,
      userName: data['userName'] as String? ?? '',
      userToken: data['userToken'] as String? ?? '',
      userFirstName: data['userFirstName'] as String? ?? '',
      userLastName: data['userLastName'] as String? ?? '',
      userFullName: data['userFullName'] as String? ?? '',
      userType: data['userType'] as String ?? '',
      userMobileNumber: data['userMobileNumber'] as String? ?? '',
      userEmailAddress: data['userEmailAddress'] as String? ?? '',
      roleId: data['roleId'] as int,
      roleName: data['roleName'] as String? ?? '',
      userStateLGDCode: data['userStateLGDCode'] as int,
      userDistrictLGDCode: data['userDistrictLGDCode'] as int,
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      isMobileVerified: data['isMobileVerified'] as bool? ?? false,
      isPasswordChanged: data['isPasswordChanged'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      territoryLevel: data['territoryLevel'] as String? ?? '',
      department: DepartmentModel.fromJson(
        data['departmentId'] as Map<String, dynamic>,
      ),
      stateName: data['stateName'] == '' ? null : data['stateName'] as String?,
      districtName: data['districtName'] as String?,
      lastPasswordChangedDate: data['lastPasswordChangedDate'] == null
          ? null
          : DateTime.tryParse(data['lastPasswordChangedDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userToken': userToken,
      'userFirstName': userFirstName,
      'userLastName': userLastName,
      'userFullName': userFullName,
      'userType': userType,
      'userMobileNumber': userMobileNumber,
      'userEmailAddress': userEmailAddress,
      'roleId': roleId,
      'roleName': roleName,
      'userStateLGDCode': userStateLGDCode,
      'userDistrictLGDCode': userDistrictLGDCode,
      'isEmailVerified': isEmailVerified,
      'isMobileVerified': isMobileVerified,
      'isPasswordChanged': isPasswordChanged,
      'isActive': isActive,
      'territoryLevel': territoryLevel,
      'departmentId': department.toJson(),
      'stateName': stateName,
      'districtName': districtName,
      'lastPasswordChangedDate': lastPasswordChangedDate?.toIso8601String(),
    };
  }
}