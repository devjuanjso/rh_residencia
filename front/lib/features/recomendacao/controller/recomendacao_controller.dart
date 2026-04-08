import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/http_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../model/recomendacao_model.dart';

class RecomendacaoController {
  static final SecureStorageService _storage = SecureStorageService();

  // Monta headers com token de autenticacao
  static Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Busca candidatos recomendados para uma vaga especifica
  static Future<List<Recomendacao>> porVaga(String vagaId) async {
    final uri = Uri.parse('${Config.baseUrl}/recomendacoes/')
        .replace(queryParameters: {'vaga': vagaId});

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Recomendacao.fromJson(e)).toList();
    }

    throw Exception(response.body);
  }
}