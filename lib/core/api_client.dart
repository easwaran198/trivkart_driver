import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

class ApiClient {
  final StorageService _storageService = StorageService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      final rawToken = token.replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '');
      final bearerToken = 'Bearer $rawToken';

      headers['token'] = rawToken;
      headers['Token'] = rawToken;
      headers['Authorization'] = token.startsWith('Bearer ') ? token : bearerToken;
    }
    return headers;
  }

  Future<dynamic> get(String url) async {
    final headers = await _getHeaders();
    _logRequest('GET', url, headers, null);

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      _logResponse('GET', url, response.statusCode, response.body);
      return _processResponse('GET', url, response);
    } catch (e, stack) {
      _logError('GET', url, e, stack);
      rethrow;
    }
  }

  Future<dynamic> post(String url, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final encodedBody = jsonEncode(body);
    _logRequest('POST', url, headers, body);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: encodedBody,
      );
      _logResponse('POST', url, response.statusCode, response.body);
      return _processResponse('POST', url, response);
    } catch (e, stack) {
      _logError('POST', url, e, stack);
      rethrow;
    }
  }

  dynamic _processResponse(String method, String url, http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      try {
        return jsonDecode(response.body);
      } catch (e) {
        debugPrint('⚠️ [API PARSE WARNING] Unable to parse JSON response for $url');
        return response.body;
      }
    } else {
      String errorMessage = 'Server error (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('message')) {
          errorMessage = decoded['message'];
        }
      } catch (_) {}

      debugPrint('❌ [API ERROR CODE] $method $url returned HTTP ${response.statusCode}: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  void _logRequest(String method, String url, Map<String, String> headers, dynamic body) {
    debugPrint('\n==================== 🌐 [API REQUEST] ====================');
    debugPrint('📌 METHOD  : $method');
    debugPrint('🔗 URL     : $url');
    debugPrint('📋 HEADERS : ${jsonEncode(headers)}');
    if (body != null) {
      debugPrint('📦 PAYLOAD : ${jsonEncode(body)}');
    }
    debugPrint('=========================================================\n');
  }

  void _logResponse(String method, String url, int statusCode, String responseBody) {
    debugPrint('\n==================== 📡 [API RESPONSE] ====================');
    debugPrint('🔗 URL     : $url');
    debugPrint('📊 STATUS  : $statusCode');
    debugPrint('📄 RESPONSE: $responseBody');
    debugPrint('=========================================================\n');
  }

  void _logError(String method, String url, dynamic error, StackTrace stack) {
    debugPrint('\n==================== ❌ [API EXCEPTION] ====================');
    debugPrint('🔗 URL     : $url');
    debugPrint('💥 ERROR   : $error');
    debugPrint('📚 STACK   : $stack');
    debugPrint('=========================================================\n');
  }
}
