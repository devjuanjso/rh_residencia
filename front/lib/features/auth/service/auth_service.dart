import 'dart:convert';
import 'package:front/core/services/api_client.dart';
import 'package:front/core/services/http_service.dart';
import 'package:front/core/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await _storage.saveToken(data['access'] as String);
      await _storage.saveRefreshToken(data['refresh'] as String);
      return data;
    }

    // extrai mensagem de erro do corpo da resposta
    String mensagem = 'Usuário ou senha incorretos';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final detail = body['detail'] ?? body['non_field_errors'];
      if (detail is List && detail.isNotEmpty) {
        mensagem = detail.first.toString();
      } else if (detail != null) {
        mensagem = detail.toString();
      }
    } catch (_) {}

    throw Exception(mensagem);
  }

  // Busca os dados do usuário autenticado no backend.
  Future<Map<String, dynamic>?> fetchMe() async {
    try {
      final response = await ApiClient.get('/users/me/');
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> refreshAccessToken() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh == null) return null;

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refresh}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final newAccess = data['access'] as String;
      await _storage.saveToken(newAccess);
      return newAccess;
    }

    await _storage.deleteToken();
    return null;
  }

  Future<String?> getAccessToken() async => _storage.getToken();
}
