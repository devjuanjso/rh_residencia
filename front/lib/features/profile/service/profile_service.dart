import 'dart:convert';
import 'package:front/core/services/http_service.dart';
import 'package:http/http.dart' as http;
import 'package:front/core/services/secure_storage_service.dart';

class ProfileService {
  final SecureStorageService _storage = SecureStorageService();

  Future<Map<String, dynamic>> getProfile() async {
    final token = await _storage.getToken();

    final response = await http.get(
      Uri.parse("${Config.baseUrl}/users/me/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro ao buscar perfil");
    }
  }
}