import 'dart:convert';
import 'package:http/http.dart' as http;
import 'http_service.dart';
import 'secure_storage_service.dart';

// Cliente HTTP centralizado com refresh automático de token em respostas 401.
class ApiClient {
  static final SecureStorageService _storage = SecureStorageService();

  static Future<http.Response> get(String path) =>
      _withRefresh((token) => http.get(
            Uri.parse('${Config.baseUrl}$path'),
            headers: _headers(token),
          ));

  static Future<http.Response> post(String path, {Object? body}) =>
      _withRefresh((token) => http.post(
            Uri.parse('${Config.baseUrl}$path'),
            headers: _headers(token),
            body: body != null ? jsonEncode(body) : null,
          ));

  static Future<http.Response> patch(String path, {Object? body}) =>
      _withRefresh((token) => http.patch(
            Uri.parse('${Config.baseUrl}$path'),
            headers: _headers(token),
            body: body != null ? jsonEncode(body) : null,
          ));

  static Future<http.Response> delete(String path) =>
      _withRefresh((token) => http.delete(
            Uri.parse('${Config.baseUrl}$path'),
            headers: _headers(token),
          ));

  static Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  // Executa a chamada; se receber 401, tenta renovar o token e repete uma vez.
  static Future<http.Response> _withRefresh(
    Future<http.Response> Function(String? token) call,
  ) async {
    final token = await _storage.getToken();
    final response = await call(token);

    if (response.statusCode != 401) return response;

    final newToken = await _tryRefresh();
    return call(newToken);
  }

  // Tenta renovar o access token usando o refresh token salvo.
  static Future<String?> _tryRefresh() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh == null) {
      await _storage.deleteToken();
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      if (response.statusCode == 200) {
        final newToken =
            (jsonDecode(response.body) as Map)['access'] as String;
        await _storage.saveToken(newToken);
        return newToken;
      }
    } catch (_) {}

    await _storage.deleteToken();
    return null;
  }
}
