import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'http_service.dart';
import 'secure_storage_service.dart';

class AiController {
  static final SecureStorageService _storage = SecureStorageService();

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.getToken();
    return {'Authorization': 'Bearer $token'};
  }

  // Envia PDF ao backend e retorna sugestão de projeto; erro preenchido em caso de falha.
  static Future<({Map<String, dynamic>? dados, String? erro})> sugerirProjetoPorPdf(
    File arquivo,
  ) async {
    try {
      final token = await _storage.getToken();
      final uri = Uri.parse('${Config.baseUrl}/projetos/sugerir-por-pdf/');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', arquivo.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if (response.statusCode == 200) return (dados: data, erro: null);

      final msg = data['erro'] ?? data['detail'] ?? 'Erro desconhecido';
      return (dados: null, erro: msg.toString());
    } catch (e) {
      return (dados: null, erro: 'Erro ao enviar PDF: $e');
    }
  }

  // Envia descrição textual ao backend e retorna sugestão de projeto pela IA.
  static Future<({Map<String, dynamic>? dados, String? erro})> sugerirProjetoPorTexto(
    String descricao,
  ) async {
    try {
      final token = await _storage.getToken();
      final uri = Uri.parse('${Config.baseUrl}/projetos/sugerir-por-texto/');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'descricao': descricao}),
      );
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200) return (dados: data, erro: null);
      final msg = data['erro'] ?? data['detail'] ?? 'Erro desconhecido';
      return (dados: null, erro: msg.toString());
    } catch (e) {
      return (dados: null, erro: 'Erro ao enviar descrição: $e');
    }
  }

  // Envia currículo PDF ao backend e retorna dados extraídos pela IA.
  static Future<({Map<String, dynamic>? dados, String? erro})> analisarCurriculo(
    File arquivo,
  ) async {
    try {
      final token = await _storage.getToken();
      final uri = Uri.parse('${Config.baseUrl}/colaboradores/analisar-curriculo/');
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', arquivo.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final sugestao = data['sugestao_ia'] as Map<String, dynamic>?;
        return (dados: sugestao, erro: null);
      }

      final msg = data['erro'] ?? data['detail'] ?? 'Erro desconhecido';
      return (dados: null, erro: msg.toString());
    } catch (e) {
      return (dados: null, erro: 'Erro ao enviar PDF: $e');
    }
  }
}
