import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rh_app/core/services/http_service.dart';
import 'package:rh_app/features/position/model/position_model.dart';
import 'package:rh_app/features/projects/model/project_model.dart';

class ProjectController {

  // Cria um novo projeto na API
  static Future<bool> criarProjeto({
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

      print('STATUS: ${response.statusCode}');
      print('BODY: $body');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Erro ao criar projeto: $e');
      return false;
    }
  }

  // Busca um projeto específico por ID
  static Future<Project?> buscarProjetoPorId(String projetoId) async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/projetos/$projetoId/');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Project.fromJson(data);
      } else if (response.statusCode == 404) {
        print('Projeto não encontrado');
        return null;
      } else {
        print('Erro ao buscar projeto: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar projeto: $e');
      return null;
    }
  }

  // Edita um projeto existente na API
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
        // Algumas APIs requerem uma flag para manter a imagem existente
        request.fields['manter_imagem'] = 'true';
      }

      final response = await request.send();
      final body = await response.stream.bytesToString();
      
      print('STATUS EDIÇÃO: ${response.statusCode}');
      print('BODY EDIÇÃO: $body');

      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao editar projeto: $e');
      return false;
    }
  }

  // Edição parcial do projeto (PATCH)
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

  // Exclui um projeto
  static Future<bool> excluirProjeto(String projetoId) async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/projetos/$projetoId/');
      final response = await http.delete(uri);

      if (response.statusCode == 204 || response.statusCode == 200) {
        print('Projeto excluído com sucesso');
        return true;
      } else if (response.statusCode == 404) {
        print('Projeto não encontrado para exclusão');
        return false;
      } else {
        print('Erro ao excluir projeto: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Erro ao excluir projeto: $e');
      return false;
    }
  }

  // Busca todos os projetos cadastrados na API
  static Future<List<Project>> buscarProjetos() async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/projetos/');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Project.fromJson(e)).toList();
      } else {
        print('Erro ao buscar projetos: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erro ao buscar projetos: $e');
      return [];
    }
  }

  // Busca projetos com filtros (paginação, busca, etc.)
  static Future<Map<String, dynamic>> buscarProjetosComFiltros({
    String? busca,
    int? pagina,
    int? itensPorPagina,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      
      if (busca != null && busca.isNotEmpty) {
        queryParams['busca'] = busca;
      }
      if (pagina != null) {
        queryParams['pagina'] = pagina.toString();
      }
      if (itensPorPagina != null) {
        queryParams['itens_por_pagina'] = itensPorPagina.toString();
      }

      final uri = Uri.parse('${Config.baseUrl}/projetos/')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Adapte conforme a estrutura da sua API
        // Exemplo de retorno comum com paginação:
        if (data is Map && data.containsKey('results')) {
          final List projetosData = data['results'];
          final projetos = projetosData.map((e) => Project.fromJson(e)).toList();
          
          return {
            'projetos': projetos,
            'total': data['count'] ?? projetos.length,
            'pagina': data['current_page'] ?? pagina ?? 1,
            'total_paginas': data['total_pages'] ?? 1,
          };
        } else {
          // Caso a API não tenha estrutura de paginação
          final List projetosData = data is List ? data : [];
          final projetos = projetosData.map((e) => Project.fromJson(e)).toList();
          
          return {
            'projetos': projetos,
            'total': projetos.length,
            'pagina': 1,
            'total_paginas': 1,
          };
        }
      } else {
        print('Erro ao buscar projetos com filtros: ${response.statusCode}');
        return {'projetos': [], 'total': 0, 'pagina': 1, 'total_paginas': 1};
      }
    } catch (e) {
      print('Erro ao buscar projetos com filtros: $e');
      return {'projetos': [], 'total': 0, 'pagina': 1, 'total_paginas': 1};
    }
  }

  // Busca vagas associadas a um projeto específico
  static Future<List<Position>> buscarVagasPorProjeto(String projetoId) async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/vagas/por-projeto/$projetoId/');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Position.fromJson(e)).toList();
      } else {
        print('Erro ao buscar vagas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Erro ao buscar vagas: $e');
      return [];
    }
  }
}