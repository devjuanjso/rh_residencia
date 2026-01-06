import 'package:http/http.dart' as http;
import 'package:rh_app/core/services/http_service.dart';
import 'dart:convert';

class PositionController {
  static Future<bool> criarVaga({
    required String titulo,
    required String descricao,
    required String projectId,
    required List<String> habilidadesRequeridas,
    required List<String> certificacoesRequeridas,
    required List<String> formacaoDesejada,
  }) async {
    try {
      final uri = Uri.parse('${Config.baseUrl}/vaga/');
      final request = http.MultipartRequest('POST', uri);

      request.fields['titulo'] = titulo;
      request.fields['descricao'] = descricao;
      request.fields['projectId'] = projectId;
      request.fields['habilidadesRequeridas'] = jsonEncode(habilidadesRequeridas);
      request.fields['certificacoesRequeridas'] = jsonEncode(certificacoesRequeridas);
      request.fields['formacaoDesejada'] = jsonEncode(formacaoDesejada);

      final response = await request.send();
      final body = await response.stream.bytesToString();

      print('STATUS: ${response.statusCode}');
      print('BODY: $body');

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Erro ao criar vaga: $e');
      return false;
    }
  }
}
