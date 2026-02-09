import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/services/http_service.dart';
import '../../position/model/position_model.dart';
import '../model/project_model.dart';

class ProjectController {
  
  static Future<String?> criarProjeto({
    required String nome,
    required String descricao,
    File? imagem,
  }) async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/projetos/');
      final request = http.MultipartRequest('POST', uri);

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
        return data['id']?.toString() ?? data['_id']?.toString();
      }
      return null;
    } catch (e) {
      print('Erro ao criar projeto: $e');
      return null;
    }
  }

  static Future<Project?> buscarProjetoPorId(String projetoId) async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/projetos/$projetoId/');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Project.fromJson(data);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Erro ao buscar projeto: $e');
      return null;
    }
  }

  static Future<bool> editarProjeto({
    required String projetoId,
    required String nome,
    required String descricao,
    File? imagem,
    bool? manterImagemAtual,
  }) async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/projetos/$projetoId/');
      final request = http.MultipartRequest('PUT', uri);

      request.fields['nome'] = nome;
      request.fields['descricao'] = descricao;
      
      if (imagem != null) {
        request.files.add(
          await http.MultipartFile.fromPath('imagem', imagem.path),
        );
      } else if (manterImagemAtual != null && manterImagemAtual) {
        request.fields['manter_imagem'] = 'true';
      }

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao editar projeto: $e');
      return false;
    }
  }

  static Future<bool> atualizarProjetoParcial({
    required String projetoId,
    String? nome,
    String? descricao,
    File? imagem,
  }) async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/projetos/$projetoId/');
      final request = http.MultipartRequest('PATCH', uri);

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

  static Future<bool> excluirProjeto(String projetoId) async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/projetos/$projetoId/');
      final response = await http.delete(uri);

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 404) {
        return false;
      } else {
        return false;
      }
    } catch (e) {
      print('Erro ao excluir projeto: $e');
      return false;
    }
  }

  static Future<List<Project>> buscarProjetos() async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/projetos/');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Project.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Erro ao buscar projetos: $e');
      return [];
    }
  }

  static Future<List<Position>> buscarVagasPorProjeto(String projetoId) async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/vagas/por-projeto/$projetoId/');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Position.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Erro ao buscar vagas: $e');
      return [];
    }
  }
}