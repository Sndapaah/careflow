import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../error/failure.dart';
import 'api_config.dart';
import 'token_storage.dart';

class ApiClient {
  ApiClient({http.Client? client, TokenStorage? tokenStorage})
    : _client = client ?? http.Client(),
      _tokenStorage = tokenStorage ?? const TokenStorage();

  final http.Client _client;
  final TokenStorage _tokenStorage;

  /// A request that hasn't come back within this window is treated as a
  /// network failure rather than being left to hang the caller forever.
  static const Duration _timeout = Duration(seconds: 12);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
    Duration? timeout,
  }) => _send(
    'POST',
    path,
    body: body,
    authenticated: authenticated,
    timeout: timeout,
  );

  Future<Map<String, dynamic>> get(
    String path, {
    bool authenticated = false,
    Duration? timeout,
  }) =>
      _send(
        'GET',
        path,
        authenticated: authenticated,
        timeout: timeout,
      );

  Future<Map<String, dynamic>> patch(String path, {Map<String, dynamic>? body, bool authenticated = false}) =>
      _send('PATCH', path, body: body, authenticated: authenticated);

  Future<Map<String, dynamic>> delete(String path, {bool authenticated = false}) =>
      _send('DELETE', path, authenticated: authenticated);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required bool authenticated,
    Duration? timeout,
  }) async {
    final Uri uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final String? token = await _tokenStorage.read();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      response =
          await (method == 'GET'
                  ? _client.get(uri, headers: headers)
                  : method == 'PATCH'
                  ? _client.patch(uri, headers: headers, body: body == null ? null : jsonEncode(body))
                  : method == 'DELETE'
                  ? _client.delete(uri, headers: headers)
                  : _client.post(
                      uri,
                      headers: headers,
                      body: body == null ? null : jsonEncode(body),
                    ))
              .timeout(timeout ?? _timeout);
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure('The server took too long to respond.');
    }

    final Map<String, dynamic> decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (kDebugMode) {
      debugPrint(
        'API $method $path -> ${response.statusCode}; '
        'fields: ${decoded.keys.join(', ')}',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final String message =
        decoded['message'] as String? ?? 'Something went wrong.';

    switch (response.statusCode) {
      case 401:
      case 403:
        throw AuthFailure(message);
      case 404:
        throw NotFoundFailure(message);
      default:
        throw ServerFailure(message);
    }
  }
}
