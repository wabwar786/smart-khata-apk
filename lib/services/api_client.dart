import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
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

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final session = await SessionService.get();
      if (session == null) throw ApiException('Session expired. Please login again.');
      headers['Authorization'] = 'Bearer ${session.token}';
      headers['x-business-id'] = session.businessPublicId;
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query, bool auth = true}) async {
    final response = await http.get(_uri(path, query), headers: await _headers(auth: auth));
    return _handle(response);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final response = await http.post(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final response = await http.put(
      _uri(path),
      headers: await _headers(auth: auth),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  Map<String, dynamic> _handle(http.Response response) {
    final body = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      body['message']?.toString() ?? body['error']?.toString() ?? 'Request failed',
      statusCode: response.statusCode,
    );
  }
}
