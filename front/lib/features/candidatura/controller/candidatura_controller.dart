import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:front/features/candidatura/model/candidatura_model.dart';
import 'package:http/http.dart' as http;
import 'package:front/core/services/http_service.dart';
import 'package:front/core/services/secure_storage_service.dart';

class CandidaturaController {
  final SecureStorageService _storage = SecureStorageService();

  Future<bool> candidatarSe({required String vagaId}) async {
    final token = await _storage.getToken();

    if (token == null) throw Exception("Usuário não autenticado");

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/candidaturas/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"vaga": vagaId}),
    );

    if (response.statusCode == 201) return true;

    if (response.statusCode == 400) {
      final data = jsonDecode(response.body);
      throw Exception(data.toString());
    }

    throw Exception("Erro ao se candidatar");
  }

  Future<List<String>> minhasCandidaturas() async {
    final token = await _storage.getToken();

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/candidaturas/minhas/'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map<String>((e) => e.toString()).toList();
    }

    return [];
  }

  // "aceito" ou "rejeitado"
  Future<bool> decidir({
    required String candidaturaId,
    required String decisao,
  }) async {
    final token = await _storage.getToken();

    if (token == null) throw Exception("Usuário não autenticado");

    final response = await http.patch(
      Uri.parse('${Config.baseUrl}/candidaturas/$candidaturaId/decidir/'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"status": decisao}),
    );

    if (response.statusCode == 200) return true;

    if (response.statusCode == 400 || response.statusCode == 403) {
      final data = jsonDecode(response.body);
      throw Exception(data['detail'] ?? 'Erro ao decidir');
    }

    throw Exception("Erro ao processar decisão");
  }

  Future<List<Candidatura>> minhasCandidaturasCompletas() async {
    final token = await _storage.getToken();

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/candidaturas/minhas/'),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Candidatura.fromJson(e)).toList();
    }

    return [];
  }
}