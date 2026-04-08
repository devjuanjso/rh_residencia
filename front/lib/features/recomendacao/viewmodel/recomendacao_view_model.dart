import 'package:flutter/material.dart';
import 'package:front/features/recomendacao/controller/recomendacao_controller.dart';
import 'package:front/features/recomendacao/model/recomendacao_model.dart';

class RecomendacaoViewModel extends ChangeNotifier {
  List<Recomendacao> recomendacoes = [];
  bool isLoading = false;
  String errorMessage = '';

  // carrega e ordena candidatos da vaga por compatibilidade
  Future<void> carregar(String vagaId) async {
    isLoading = true;
    errorMessage = '';
    recomendacoes = [];
    notifyListeners();

    try {
      final lista = await RecomendacaoController.porVaga(vagaId);
      lista.sort((a, b) => b.compatibilidade.compareTo(a.compatibilidade));
      recomendacoes = lista;
    } catch (e) {
      errorMessage = 'Erro ao carregar candidatos: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}