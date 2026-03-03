import 'dart:convert';
import 'package:front/core/services/http_service.dart';
import 'package:http/http.dart' as http;

class AuthService {
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
      return jsonDecode(response.body);
    } else {
      throw Exception("Erro ao fazer login");
    }
  }
}