import 'dart:convert';
import 'package:front/core/services/http_service.dart';
import 'package:front/core/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

class AuthService {

  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, dynamic>> login(
      String username, String password) async {

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/login/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await _storage.saveToken(data["access"]);
      await _storage.saveRefreshToken(data["refresh"]);

      return data;
    } else {
      throw Exception("Erro ao fazer login");
    }
  }

  Future<String?> refreshAccessToken() async {

    final refresh = await _storage.getRefreshToken();

    if (refresh == null) {
      return null;
    }

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/refresh/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "refresh": refresh,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newAccess = data["access"];

      await _storage.saveToken(newAccess);

      return newAccess;
    } else {
      await _storage.deleteToken();
      return null;
    }
  }
}