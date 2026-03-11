import 'dart:convert';
import 'package:front/core/services/http_service.dart';
import 'package:front/features/auth/service/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:front/core/services/secure_storage_service.dart';

class ProfileService {
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, dynamic>> getProfile() async {
    String? token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token não encontrado");
    }

    var response = await http.get(
      Uri.parse("${Config.baseUrl}/users/me/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    // Se token expirou tenta refresh automático
    if (response.statusCode == 401 || response.statusCode == 403) {
      final authService = AuthService();
      final newToken = await authService.refreshAccessToken();

      if (newToken != null) {
        response = await http.get(
          Uri.parse("${Config.baseUrl}/users/me/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $newToken",
          },
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
      }
    }

    // Mensagem de erro mais informativa para facilitar debugging
    throw Exception(
        "Erro ao buscar perfil: ${response.statusCode} - ${response.body}");
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    String? token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("Token não encontrado");
    }

    var response = await http.patch(
      Uri.parse("${Config.baseUrl}/users/me/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    // Se token expirou tenta refresh automático
    if (response.statusCode == 401 || response.statusCode == 403) {
      final authService = AuthService();
      final newToken = await authService.refreshAccessToken();

      if (newToken != null) {
        response = await http.put(
          Uri.parse("${Config.baseUrl}/users/me/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $newToken",
          },
          body: jsonEncode(data),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return;
        }
      }
    }

    throw Exception(
        "Erro ao atualizar perfil: ${response.statusCode} - ${response.body}");
  }

  Future<Map<String, dynamic>> getChoices() async {
    String? token = await _storage.getToken();

    var response = await http.get(
      Uri.parse("${Config.baseUrl}/users/choices/"),
      headers: {
        "Content-Type": "application/json",
        if (token != null && token.isNotEmpty)
          "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      final authService = AuthService();
      final newToken = await authService.refreshAccessToken();

      if (newToken != null) {
        response = await http.get(
          Uri.parse("${Config.baseUrl}/users/choices/"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $newToken",
          },
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
      }
    }

    throw Exception(
        "Erro ao buscar opções: ${response.statusCode} - ${response.body}");
  }
}