import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rh_app/core/services/http_service.dart';

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
          await http.MultipartFile.fromPath(
            'imagem',
            imagem.path,
          ),
        );
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        print('Projeto criado com sucesso');
        return true;
      } else {
        print('Erro ao criar projeto');
        print('Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erro de conexão');
      print(e);
      return false;
    }
  }
}
