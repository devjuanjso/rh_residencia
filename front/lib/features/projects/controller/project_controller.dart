import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../core/services/http_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../position/model/position_model.dart';
import '../model/project_model.dart';

class ProjectController {

  static final SecureStorageService _storage = SecureStorageService();

  // Retorna headers com token de autenticação
  static Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.getToken();

    return {
      "Authorization": "Bearer $token",
    };
  }

  // Cria um novo projeto
  static Future<String?> criarProjeto({
    required String nome,
    required String descricao,
    File? imagem,
  }) async {
    try {

      final uri = Uri.parse('${Config.baseUrl}/projetos/');
      final token = await _storage.getToken();

      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['nome'] = nome;
      request.fields['descricao'] = descricao;

      if (imagem != null) {
        request.files.add(
          await http.MultipartFile.fromPath('imagem', imagem.path),
        );
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(body);
        return data['id']?.toString();
      }

      return null;

    } catch (e) {
      print('Erro ao criar projeto: $e');
      return null;
    }
  }

  // Busca um projeto específico pelo ID
  static Future<Project?> buscarProjetoPorId(String projetoId) async {
    try {

      final headers = await _authHeaders();
      final uri = Uri.parse('${Config.baseUrl}/projetos/$projetoId/');

      final response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Project.fromJson(data);
      }

      return null;

    } catch (e) {
      print('Erro ao buscar projeto: $e');
      return null;
    }
  }

  // Atualiza completamente um projeto
  static Future<bool> editarProjeto({
    required String projetoId,
    required String nome,
    required String descricao,
    File? imagem,
    bool? manterImagemAtual,
  }) async {

    try {

      final uri = Uri.parse('${Config.baseUrl}/projetos/$projetoId/');
      final token = await _storage.getToken();

      final request = http.MultipartRequest('PUT', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.fields['nome'] = nome;
      request.fields['descricao'] = descricao;

      if (imagem != null) {
        request.files.add(
          await http.MultipartFile.fromPath('imagem', imagem.path),
        );
      } else if (manterImagemAtual == true) {
        request.fields['manter_imagem'] = 'true';
      }

      final response = await request.send();

      return response.statusCode == 200;

    } catch (e) {
      print('Erro ao editar projeto: $e');
      return false;
    }
  }

  // Atualiza parcialmente um projeto
  static Future<bool> atualizarProjetoParcial({
    required String projetoId,
    String? nome,
    String? descricao,
    File? imagem,
  }) async {

    try {

      final uri = Uri.parse('${Config.baseUrl}/projetos/$projetoId/');
      final token = await _storage.getToken();

      final request = http.MultipartRequest('PATCH', uri);

      request.headers['Authorization'] = 'Bearer $token';

      if (nome != null) request.fields['nome'] = nome;
      if (descricao != null) request.fields['descricao'] = descricao;

      if (imagem != null) {
        request.files.add(
          await http.MultipartFile.fromPath('imagem', imagem.path),
        );
      }

      final response = await request.send();

      return response.statusCode == 200;

    } catch (e) {
      print('Erro ao atualizar projeto parcialmente: $e');
      return false;
    }
  }

  // Remove um projeto
  static Future<bool> excluirProjeto(String projetoId) async {

    try {

      final headers = await _authHeaders();
      final uri = Uri.parse('${Config.baseUrl}/projetos/$projetoId/');

      final response = await http.delete(
        uri,
        headers: headers,
      );

      return response.statusCode == 204 || response.statusCode == 200;

    } catch (e) {
      print('Erro ao excluir projeto: $e');
      return false;
    }
  }

  // Lista projetos publicados
  static Future<List<Project>> buscarProjetosPublicados() async {

    try {

      final headers = await _authHeaders();
      final uri = Uri.parse('${Config.baseUrl}/projetos/publicados/');

      final response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {

        final List data = jsonDecode(response.body);

        return data.map((e) => Project.fromJson(e)).toList();
      }

      return [];

    } catch (e) {
      print('Erro ao buscar projetos publicados: $e');
      return [];
    }
  }

  // Lista projetos criados pelo usuário logado
  static Future<List<Project>> buscarMeusProjetos() async {

    try {

      final headers = await _authHeaders();
      final uri = Uri.parse('${Config.baseUrl}/projetos/meus/');

      final response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {

        final List data = jsonDecode(response.body);

        return data.map((e) => Project.fromJson(e)).toList();
      }

      return [];

    } catch (e) {
      print('Erro ao buscar meus projetos: $e');
      return [];
    }
  }

  // Lista vagas associadas a um projeto
  static Future<List<Position>> buscarVagasPorProjeto(String projetoId) async {

    try {

      final headers = await _authHeaders();
      final uri = Uri.parse('${Config.baseUrl}/vagas/por-projeto/$projetoId/');

      final response = await http.get(
        uri,
        headers: headers,
      );

      if (response.statusCode == 200) {

        final List data = jsonDecode(response.body);

        return data.map((e) => Position.fromJson(e)).toList();
      }

      return [];

    } catch (e) {
      print('Erro ao buscar vagas: $e');
      return [];
    }
  }
}