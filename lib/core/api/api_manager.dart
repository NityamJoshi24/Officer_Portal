import 'api_response_status.dart';
import 'api_services.dart';

class ApiManager {
  final api = ApiServices.instance;

  static const String verifyCredentialsUrl =
      'https://betadcs.agristack.gov.in/agristackag/crop-survey-api-beta/agristack/v1/api/authenticate/user/verifyCredentials';

  static const String mobileLoginUrl =
      'https://betadcs.agristack.gov.in/agristackag/crop-survey-api-beta/agristack/v1/api/authenticate/user/mobile/login';

  static const String logoutUrl =
      'https://betadcs.agristack.gov.in/agristackag/crop-survey-api-beta/agristack/v1/api/authenticate/user/mobile/logout';

  static const String stateListUrl =
      'https://agristack.gov.in/agristack-api/v1/dcsAPKController/getDcsStateList';

  Future<Result<dynamic>> verifyCredentials(String mobile, String password) {
    return api.post(
      verifyCredentialsUrl,
      {
        'userName': mobile,
        'userPassword': password,
        'isMobileLogin': true,
        'isFarmerGrievance': false,
      },
    );
  }

  Future<Result<dynamic>> mobileLogin({
    String? token,
    required String otp,
    required String password,
    required String mobile,
  }) {
    final payload = <String, dynamic>{
      'appVersion': '2.10',
      'deviceName': 'android',
      'imeiNumber': mobile,
      'isSigned': 'SignedApkIsTrue',
      'os': 'android',
      'otp': otp,
      'userName': mobile,
      'userPassword': password,
      'userType': 'SUPERVISOR',
      'verificationSource': mobile,
    };

    if (token != null && token.trim().isNotEmpty) {
      payload['token'] = token;
    }

    return api.post(
      mobileLoginUrl,
      payload,
    );
  }

  Future<Result<dynamic>> logout(String token, int userId) {
    return api.post(
      logoutUrl,
      {'userId': userId},
      customHeaders: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'language': 'en',
        'Authorization': 'Bearer $token',
        'userId': '$userId',
      },
    );
  }

  Future<Result<dynamic>> getStateList() {
    return api.get(stateListUrl);
  }

  String? extractMessage(dynamic response) {
    if (response is! Map<String, dynamic>) {
      return null;
    }

    final nestedData = response['data'];
    final nestedMap = nestedData is Map<String, dynamic> ? nestedData : null;
    final candidates = <dynamic>[
      response['message'],
      response['responseMessage'],
      response['error'],
      nestedMap?['message'],
      nestedMap?['responseMessage'],
      nestedMap?['error'],
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    return null;
  }

  String? extractSessionToken(dynamic response) {
    if (response is! Map<String, dynamic>) {
      return null;
    }

    final nestedData = response['data'];
    final nestedMap = nestedData is Map<String, dynamic> ? nestedData : null;
    final candidates = <dynamic>[
      nestedMap?['token'],
      nestedMap?['userToken'],
      nestedMap?['accessToken'],
      response['token'],
      response['userToken'],
      response['accessToken'],
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    return null;
  }

  bool isOtpVerified(dynamic response) {
    if (response is! Map<String, dynamic>) {
      return false;
    }

    final nestedData = response['data'];
    final nestedMap = nestedData is Map<String, dynamic> ? nestedData : null;
    final candidates = <dynamic>[
      nestedMap?['isVerified'],
      response['isVerified'],
      nestedMap?['verified'],
      response['verified'],
      nestedMap?['success'],
      response['success'],
    ];

    for (final candidate in candidates) {
      if (candidate is bool) {
        return candidate;
      }
    }

    final code = response['code'] ?? response['responseCode'];
    if (code is num) {
      return code >= 200 && code < 300;
    }
    if (code is String) {
      final parsedCode = int.tryParse(code);
      if (parsedCode != null) {
        return parsedCode >= 200 && parsedCode < 300;
      }
    }

    final status = response['status'];
    if (status is String) {
      final normalizedStatus = status.toLowerCase();
      return normalizedStatus == 'success' || normalizedStatus == 'ok';
    }
    if (status is bool) {
      return status;
    }

    return nestedMap != null;
  }

  List<String> parseStates(dynamic response) {
    final list = _extractList(response);
    return list
        .map((item) {
          if (item is String) {
            return item.trim();
          }
          if (item is Map<String, dynamic>) {
            final candidates = <dynamic>[
              item['stateName'],
              item['name'],
              item['state'],
            ];
            for (final candidate in candidates) {
              if (candidate is String && candidate.trim().isNotEmpty) {
                return candidate.trim();
              }
            }
          }
          return '';
        })
        .where((state) => state.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) {
      return response;
    }
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List) {
        return data;
      }
      if (data is Map<String, dynamic>) {
        for (final key in const ['records', 'items', 'content', 'list']) {
          final nested = data[key];
          if (nested is List) {
            return nested;
          }
        }
      }
    }
    return const [];
  }
}
