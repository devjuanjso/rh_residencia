import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rh_app/core/services/http_service.dart';
import 'package:rh_app/features/position/model/position_model.dart';
import 'package:rh_app/features/projects/model/project_model.dart';

class ProjectController {
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

  static Future<bool> editarProjeto({
    required String nome,
    required String descricao,
    File? imagem,
  }) async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/projetos/%id/');
      final request = http.MultipartRequest('PUT', uri);

      request.fields['nome'] = nome;
      request.fields['descricao'] = descricao;

      // imagem só envia se o usuário trocou
      if (imagem != null) {
        request.files.add(
        await http.MultipartFile.fromPath('imagem', imagem.path),
      );
    }
    final response = await request.send();
    final body = await response.stream.bytesToString();

    print('STATUS EDITAR: ${response.statusCode}');
    print('BODY EDITAR: $body');

    return response.statusCode == 200;
    } catch (e) {
      print('Erro ao editar projeto: $e');
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
        print('Erro ao buscar projetos: ${response.statusCode}');
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
    print('🔎 Buscando vagas em: $uri');

    final response = await http.get(uri);

    print('🌐 STATUS VAGAS: ${response.statusCode}');
    print('📩 BODY VAGAS: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      print('📦 LISTA RECEBIDA: $data');

      final vagas = data.map((e) => Position.fromJson(e)).toList();

      print('✅ VAGAS CONVERTIDAS: $vagas');
      return vagas;
    } else {
      print('❌ Erro ao buscar vagas: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('💥 Erro ao buscar vagas: $e');
    return [];
  }
}
}
