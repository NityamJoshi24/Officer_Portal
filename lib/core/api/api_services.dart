import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../network_util.dart';
import 'api_response_status.dart';

class ApiServices {
  ApiServices._();
  static final instance = ApiServices._();

  final String baseUrl = 'https://betadcs.agristack.gov.in/';

  final Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void setAuthToken(String token) {
    defaultHeaders['Authorization'] = 'Bearer $token';
  }

  Future<Result<dynamic>> get(
    String endpoint, {
    Map<String, String>? customHeaders,
  }) async {
    if (!(await NetworkUtil.isConnected())) {
      return Result.failure('No internet connection');
    }

    try {
      final response = await http
          .get(
            Uri.parse(endpoint),
            headers: customHeaders ?? defaultHeaders,
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on TimeoutException {
      return Result.failure('Request timeout');
    } on SocketException {
      return Result.failure(
        'Unable to reach server. Please check your connection.',
      );
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Future<Result<dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? customHeaders,
  }) async {
    if (!(await NetworkUtil.isConnected())) {
      return Result.failure('No internet connection');
    }

    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
            headers: customHeaders ?? defaultHeaders,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on TimeoutException {
      return Result.failure('Request timeout');
    } on SocketException {
      return Result.failure(
        'Unable to reach server. Please check your connection.',
      );
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  Result<dynamic> _handleResponse(http.Response response) {
    dynamic data;

    try {
      data = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      return Result.failure('Invalid response format');
    }

    final message = _extractMessage(data);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (_isBusinessFailure(data)) {
        return Result.failure(message ?? 'Request failed');
      }
      return Result.success(data);
    }

    return Result.failure(
      message ?? 'Request failed with status ${response.statusCode}',
    );
  }

  bool _isBusinessFailure(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return false;
    }

    final code = data['code'] ?? data['responseCode'];
    if (code is num) {
      return code < 200 || code >= 300;
    }
    if (code is String) {
      final parsedCode = int.tryParse(code);
      if (parsedCode != null) {
        return parsedCode < 200 || parsedCode >= 300;
      }

      final normalizedCode = code.toLowerCase();
      if (normalizedCode.contains('fail') || normalizedCode.contains('error')) {
        return true;
      }
    }

    final status = data['status'];
    if (status is bool) {
      return !status;
    }
    if (status is String) {
      final normalizedStatus = status.toLowerCase();
      if (normalizedStatus == 'success' || normalizedStatus == 'ok') {
        return false;
      }
      if (normalizedStatus.contains('fail') ||
          normalizedStatus.contains('error') ||
          normalizedStatus == 'false') {
        return true;
      }
    }

    final success = data['success'];
    if (success is bool) {
      return !success;
    }

    return false;
  }

  String? _extractMessage(dynamic data) {
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final nestedData = data['data'];
    final nestedMap = nestedData is Map<String, dynamic> ? nestedData : null;
    final candidates = <dynamic>[
      data['message'],
      data['responseMessage'],
      data['error_description'],
      data['error'],
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
}
