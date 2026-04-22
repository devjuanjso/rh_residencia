import 'dart:convert';
import 'package:front/core/services/api_client.dart';
import 'package:front/features/candidatura/model/candidatura_model.dart';

class CandidaturaController {
  Future<bool> candidatarSe({required String vagaId}) async {
    final response = await ApiClient.post(
      '/candidaturas/',
      body: {'vaga': vagaId},
    );

    if (response.statusCode == 201) return true;

    if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      // candidatura duplicada chega como lista ou string em non_field_errors
      final erros = data['non_field_errors'];
      if (erros is List && erros.isNotEmpty) {
        throw Exception(erros.first.toString());
      }
      throw Exception(data.toString());
    }

    throw Exception('Erro ao se candidatar');
  }

  Future<bool> decidir({
    required String candidaturaId,
    required String decisao,
  }) async {
    final response = await ApiClient.patch(
      '/candidaturas/$candidaturaId/decidir/',
      body: {'status': decisao},
    );

    if (response.statusCode == 200) return true;

    if (response.statusCode == 400 || response.statusCode == 403) {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Erro ao decidir');
    }

    throw Exception('Erro ao processar decisão');
  }

  Future<List<Candidatura>> minhasCandidaturasCompletas() async {
    final response = await ApiClient.get('/candidaturas/minhas/');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Candidatura.fromJson(e)).toList();
    }

    return [];
  }

  Future<List<Candidatura>> candidaturasPorVaga(String vagaId) async {
    final response = await ApiClient.get('/candidaturas/por-vaga/$vagaId/');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Candidatura.fromJson(e)).toList();
    }

    if (response.statusCode == 403) {
      throw Exception('Sem permissão para ver os candidatos desta vaga.');
    }

    return [];
  }
}
