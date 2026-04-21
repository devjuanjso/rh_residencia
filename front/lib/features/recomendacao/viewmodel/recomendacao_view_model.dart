import 'package:flutter/material.dart';
import 'package:front/features/candidatura/controller/candidatura_controller.dart';
import 'package:front/features/recomendacao/controller/recomendacao_controller.dart';
import 'package:front/features/recomendacao/model/recomendacao_model.dart';

class RecomendacaoViewModel extends ChangeNotifier {
  List<Recomendacao> recomendacoes = [];
  bool isLoading = false;
  bool isProcessando = false;
  String errorMessage = '';
  String? decisaoFeita;      // 'aceito' | 'rejeitado' | null
  String? candidatoDecidido; // nome do candidato para exibir no overlay

  final _candidaturaController = CandidaturaController();

  bool jaDecidido(String status) => status == 'aceito' || status == 'rejeitado';

  Color corCompatibilidade(double valor) {
    if (valor >= 0.7) return const Color(0xFF16A34A);
    if (valor >= 0.4) return const Color(0xFFD97706);
    return const Color(0xFFDC2626);
  }

  ({Color cor, Color bg, String label, IconData icon}) dadosBadgeStatus(String status) {
    final aceito = status == 'aceito';
    final cor = aceito ? const Color(0xFF16A34A) : Colors.red;
    return (
      cor: cor,
      bg: cor.withOpacity(0.10),
      label: aceito ? 'Aceito' : 'Rejeitado',
      icon: aceito ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
    );
  }

  ({Color cor, Color bg, IconData icon, String titulo}) dadosOverlay(String decisao) {
    final aceito = decisao == 'aceito';
    final cor = aceito ? const Color(0xFF16A34A) : Colors.red;
    return (
      cor: cor,
      bg: cor.withOpacity(0.12),
      icon: aceito ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
      titulo: aceito ? 'Candidato aceito!' : 'Candidato rejeitado',
    );
  }

  Future<void> carregar(String vagaId) async {
    isLoading = true;
    errorMessage = '';
    recomendacoes = [];
    decisaoFeita = null;
    candidatoDecidido = null;
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

  Future<bool> decidir(String candidaturaId, String decisao, String nomeCandidato) async {
    isProcessando = true;
    notifyListeners();

    try {
      final sucesso = await _candidaturaController.decidir(
        candidaturaId: candidaturaId,
        decisao: decisao,
      );

      if (sucesso) {
        final idx = recomendacoes.indexWhere((r) => r.candidaturaId == candidaturaId);
        if (idx != -1) {
          recomendacoes[idx] = recomendacoes[idx].copyWith(status: decisao);
        }
        decisaoFeita = decisao;
        candidatoDecidido = nomeCandidato;
        notifyListeners();
      }

      return sucesso;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      isProcessando = false;
      notifyListeners();
    }
  }

  void limparDecisao() {
    decisaoFeita = null;
    candidatoDecidido = null;
    notifyListeners();
  }
}