import 'dart:convert';
import 'dart:io';

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

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) => _send('POST', path, body: body, authenticated: authenticated);

  Future<Map<String, dynamic>> get(
    String path, {
    bool authenticated = false,
  }) => _send('GET', path, authenticated: authenticated);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required bool authenticated,
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
      response = method == 'GET'
          ? await _client.get(uri, headers: headers)
          : await _client.post(
              uri,
              headers: headers,
              body: body == null ? null : jsonEncode(body),
            );
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    }

    final Map<String, dynamic> decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

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