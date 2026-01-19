import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rh_app/core/services/http_service.dart';
import 'package:rh_app/features/position/model/position_model.dart';

class PositionController {
  static final Uri _baseUri = Uri.parse('${Config.baseUrl}/vagas/');

  // Retorna os headers padrão para as requisições HTTP
  static Map<String, String> _headers() => {
        'Content-Type': 'application/json',
      };

  // Cria uma nova vaga no sistema
  static Future<Position> create({
    required String projetoId,
    required String titulo,
    String? descricao,
    required List<String> habilidadesRequeridas,
    required List<String> certificacoesRequeridas,
    String? formacaoDesejada,
  }) async {
    final response = await http.post(
      _baseUri,
      headers: _headers(),
      body: jsonEncode({
        'projeto': projetoId,
        'titulo': titulo,
        'descricao': descricao,
        'habilidades_requeridas': habilidadesRequeridas,
        'certificacoes_requeridas': certificacoesRequeridas,
        'formacao_desejada': formacaoDesejada,
      }),
    );

    // Retorna a vaga criada se a requisição for bem-sucedida
    if (response.statusCode == 201) {
      return Position.fromJson(jsonDecode(response.body));
    }

    throw Exception(response.body);
  }

  // Lista todas as vagas ou filtra por projeto específico
  static Future<List<Position>> list({String? projetoId}) async {
    final uri = projetoId != null
        ? _baseUri.replace(queryParameters: {'projeto': projetoId})
        : _baseUri;

    final response = await http.get(uri, headers: _headers());

    // Converte a resposta em uma lista de objetos Position
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Position.fromJson(e)).toList();
    }

    throw Exception(response.body);
  }

  // Busca uma vaga específica pelo seu ID
  static Future<Position> getById(String id) async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/vagas/$id/'),
      headers: _headers(),
    );

    // Retorna os dados da vaga se encontrada
    if (response.statusCode == 200) {
      return Position.fromJson(jsonDecode(response.body));
    }

    throw Exception(response.body);
  }

  // Atualiza todos os campos de uma vaga existente
  static Future<Position> update({
    required String id,
    required String projetoId,
    required String titulo,
    String? descricao,
    required List<String> habilidadesRequeridas,
    required List<String> certificacoesRequeridas,
    String? formacaoDesejada,
  }) async {
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/vagas/$id/'),
      headers: _headers(),
      body: jsonEncode({
        'projeto': projetoId,
        'titulo': titulo,
        'descricao': descricao,
        'habilidades_requeridas': habilidadesRequeridas,
        'certificacoes_requeridas': certificacoesRequeridas,
        'formacao_desejada': formacaoDesejada,
      }),
    );

    // Retorna a vaga atualizada
    if (response.statusCode == 200) {
      return Position.fromJson(jsonDecode(response.body));
    }

    throw Exception(response.body);
  }

  // Atualiza parcialmente os campos de uma vaga
  static Future<Position> patch({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.patch(
      Uri.parse('${Config.baseUrl}/vagas/$id/'),
      headers: _headers(),
      body: jsonEncode(data),
    );

    // Retorna a vaga com os campos atualizados
    if (response.statusCode == 200) {
      return Position.fromJson(jsonDecode(response.body));
    }

    throw Exception(response.body);
  }

  // Remove uma vaga do sistema
  static Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse('${Config.baseUrl}/vagas/$id/'),
      headers: _headers(),
    );

    // Verifica se a exclusão foi bem-sucedida
    if (response.statusCode != 204) {
      throw Exception(response.body);
    }
  }
}