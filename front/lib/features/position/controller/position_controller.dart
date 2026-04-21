import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/http_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../model/position_model.dart';

class PositionController {
  static final SecureStorageService _storage = SecureStorageService();

  static Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<PositionChoices> getChoices() async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/vagas/choices/'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PositionChoices.fromJson(jsonDecode(response.body));
    }

    throw Exception(response.body);
  }

  static Future<Position> create({
    required String projetoId,
    required String titulo,
    String? descricao,
    String? senioridade,
    String? area,
    required List<String> habilidadesRequeridas,
    required List<String> certificacoesRequeridas,
    String? formacaoDesejada,
  }) async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/vagas/'),
      headers: await _headers(),
      body: jsonEncode({
        'projeto': projetoId,
        'titulo': titulo,
        'descricao': descricao,
        'senioridade': senioridade,
        'area': area,
        'habilidades_requeridas': habilidadesRequeridas,
        'certificacoes_requeridas': certificacoesRequeridas,
        'formacao_desejada': formacaoDesejada,
      }),
    );

    if (response.statusCode == 201) {
      return Position.fromJson(jsonDecode(response.body));
    }

    throw Exception(response.body);
  }

  static Future<List<Position>> list({String? projetoId}) async {
    final uri = projetoId != null
        ? Uri.parse('${Config.baseUrl}/vagas/')
            .replace(queryParameters: {'projeto': projetoId})
        : Uri.parse('${Config.baseUrl}/vagas/');

    final response = await http.get(uri, headers: await _headers());

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Position.fromJson(e)).toList();
    }

    throw Exception(response.body);
  }

  static Future<Position> getById(String id) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/vagas/$id/'),
      headers: await _headers(),
    );

    if (response.statusCode == 200) {
      return Position.fromJson(jsonDecode(response.body));
    }

    throw Exception(response.body);
  }

  static Future<Position> update({
    required String id,
    required String projetoId,
    required String titulo,
    String? descricao,
    String? senioridade,
    String? area,
    required List<String> habilidadesRequeridas,
    required List<String> certificacoesRequeridas,
    String? formacaoDesejada,
  }) async {
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/vagas/$id/'),
      headers: await _headers(),
      body: jsonEncode({
        'projeto': projetoId,
        'titulo': titulo,
        'descricao': descricao,
        'senioridade': senioridade,
        'area': area,
        'habilidades_requeridas': habilidadesRequeridas,
        'certificacoes_requeridas': certificacoesRequeridas,
        'formacao_desejada': formacaoDesejada,
      }),
    );

    if (response.statusCode == 200) {
      return Position.fromJson(jsonDecode(response.body));
    }

    throw Exception(response.body);
  }

  static Future<Position> patch({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.patch(
      Uri.parse('${Config.baseUrl}/vagas/$id/'),
      headers: await _headers(),
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return Position.fromJson(jsonDecode(response.body));
    }

    throw Exception(response.body);
  }

  static Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse('${Config.baseUrl}/vagas/$id/'),
      headers: await _headers(),
    );

    if (response.statusCode != 204) {
      throw Exception(response.body);
    }
  }
}