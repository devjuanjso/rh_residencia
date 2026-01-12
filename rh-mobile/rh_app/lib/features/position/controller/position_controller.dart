import 'package:http/http.dart' as http;
import 'package:rh_app/core/services/http_service.dart';
import 'dart:convert';

class PositionController {

  /// Cria uma nova vaga no backend
  static Future<bool> criarVaga({
    required String titulo,
    required String descricao,
    required String projectId,
    required List<String> habilidadesRequeridas,
    required List<String> certificacoesRequeridas,
    required List<String> formacaoDesejada,
  }) async {
    try {
      // Monta a URL base da API
      final uri = Uri.parse('${Config.baseUrl}/vaga/');

      // Requisição multipart (permite anexos e campos juntos se necessário)
      final request = http.MultipartRequest('POST', uri);

      // Campos simples do formulário
      request.fields['titulo'] = titulo;
      request.fields['descricao'] = descricao;
      request.fields['projectId'] = projectId;

      // Converte listas para JSON antes de enviar para API
      request.fields['habilidadesRequeridas'] = jsonEncode(habilidadesRequeridas);
      request.fields['certificacoesRequeridas'] = jsonEncode(certificacoesRequeridas);
      request.fields['formacaoDesejada'] = jsonEncode(formacaoDesejada);

      // Envia a requisição para o servidor
      final response = await request.send();

      return response.statusCode == 201 || response.statusCode == 200;

    } catch (e) {
      // Erro em requisição ou conversão
      print('Erro ao criar vaga: $e');
      return false;
    }
  }
}
