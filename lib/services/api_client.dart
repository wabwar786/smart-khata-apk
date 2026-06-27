import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../utils/json_utils.dart';
import 'session_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();
  static const Duration _timeout = Duration(seconds: 25);

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final queryParams = <String, String>{};
    if (query != null) {
      query.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          queryParams[key] = value.toString();
        }
      });
    }
    return Uri.parse('${AppConfig.apiBaseUrl}$normalizedPath').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
  }

  Future<Map<String, String>> _headers({bool auth = true, String? token, String? businessPublicId}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      if (businessPublicId != null && businessPublicId.isNotEmpty) {
        headers['x-business-id'] = businessPublicId;
      }
      return headers;
    }

    if (auth) {
      final session = await SessionService.get();
      if (session == null) throw ApiException('Session expired. Please login again.');
      headers['Authorization'] = 'Bearer ${session.token}';
      headers['x-business-id'] = session.businessPublicId;
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    return _safeRequest(() async {
      final response = await http
          .get(_uri(path, query), headers: await _headers(auth: auth))
          .timeout(_timeout);
      return _handle(response);
    });
  }

  Future<Map<String, dynamic>> getWithToken(String path, String token, {Map<String, dynamic>? query}) async {
    return _safeRequest(() async {
      final response = await http
          .get(_uri(path, query), headers: await _headers(auth: false, token: token))
          .timeout(_timeout);
      return _handle(response);
    });
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    return _safeRequest(() async {
      final response = await http
          .post(_uri(path), headers: await _headers(auth: auth), body: jsonEncode(body))
          .timeout(_timeout);
      return _handle(response);
    });
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body, {bool auth = true}) async {
    return _safeRequest(() async {
      final response = await http
          .put(_uri(path), headers: await _headers(auth: auth), body: jsonEncode(body))
          .timeout(_timeout);
      return _handle(response);
    });
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body, {bool auth = true}) async {
    return _safeRequest(() async {
      final response = await http
          .patch(_uri(path), headers: await _headers(auth: auth), body: jsonEncode(body))
          .timeout(_timeout);
      return _handle(response);
    });
  }

  Future<Map<String, dynamic>> _safeRequest(Future<Map<String, dynamic>> Function() request) async {
    try {
      return await request();
    } on TimeoutException {
      throw ApiException('Request timeout. Please check your internet and try again.');
    } on SocketException {
      throw ApiException('Unable to connect to server. Please check internet/DNS and try again.');
    } on FormatException {
      throw ApiException('Server returned invalid response.');
    }
  }

  Map<String, dynamic> _handle(http.Response response) {
    final decoded = response.body.trim().isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    final body = JsonUtils.map(decoded);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      JsonUtils.str(body['message'], JsonUtils.str(body['error'], 'Request failed')),
      statusCode: response.statusCode,
    );
  }
}
