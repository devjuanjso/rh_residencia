import 'package:flutter/material.dart';
import 'package:front/features/candidatura/controller/candidatura_controller.dart';
import '../../position/model/position_model.dart';
import '../controller/project_controller.dart';
import '../model/project_model.dart';

class ProjectListViewModel extends ChangeNotifier {
  List<Project> projetos = [];
  List<Position> vagasDoProjeto = [];
  bool loading = false;
  bool loadingVagas = false;
  int projetoAtual = 0;

  Set<String> vagasCandidatadas = {};

  final CandidaturaController _candidaturaController = CandidaturaController();

  // Carrega projetos publicados
  Future<void> carregarProjetosPublicados() async {
    loading = true;
    notifyListeners();

    await carregarMinhasCandidaturas();

    projetos = await ProjectController.buscarProjetosPublicados();

    loading = false;
    notifyListeners();

    if (projetos.isNotEmpty) {
      projetoAtual = 0;
      await carregarVagasDoProjetoAtual();
    }
  }

  // Carrega projetos criados pelo usuário
  Future<void> carregarMeusProjetos() async {
    loading = true;
    notifyListeners();

    await carregarMinhasCandidaturas();

    projetos = await ProjectController.buscarMeusProjetos();

    loading = false;
    notifyListeners();

    if (projetos.isNotEmpty) {
      projetoAtual = 0;
      await carregarVagasDoProjetoAtual();
    }
  }

  // Carrega vagas do projeto atual
  Future<void> carregarVagasDoProjetoAtual() async {
    if (projetos.isEmpty) return;

    final index = projetoAtual;
    if (index < 0 || index >= projetos.length) return;

    loadingVagas = true;
    notifyListeners();

    try {
      final String projetoId = projetos[index].id;
      vagasDoProjeto = await ProjectController.buscarVagasPorProjeto(projetoId);
    } catch (e) {
      vagasDoProjeto = [];
    } finally {
      loadingVagas = false;
      notifyListeners();
    }
  }

  // Define qual projeto está selecionado
  Future<void> setProjetoAtual(int index) async {
    if (index < 0 || index >= projetos.length) return;
    if (index == projetoAtual) return;

    projetoAtual = index;
    vagasDoProjeto = [];
    notifyListeners();

    await carregarVagasDoProjetoAtual();
  }

  // Avança para o próximo projeto
  Future<void> irParaProximoProjeto() async {
    if (projetos.isEmpty) return;
    if (projetoAtual >= projetos.length - 1) return;

    projetoAtual++;
    vagasDoProjeto = [];
    notifyListeners();

    await carregarVagasDoProjetoAtual();
  }

  // Realiza candidatura em uma vaga
  Future<bool> candidatarSe(String vagaId) async {
    try {
      if (vagasCandidatadas.contains(vagaId)) {
        return false;
      }

      final sucesso = await _candidaturaController.candidatarSe(
        vagaId: vagaId,
      );

      if (sucesso) {
        vagasCandidatadas.add(vagaId);
        notifyListeners();
      }

      return sucesso;
    } catch (e) {
      print("Erro ao candidatar: $e");
      rethrow;
    }
  }

  // Carrega vagas que o usuário já se candidatou
  Future<void> carregarMinhasCandidaturas() async {
    try {
      final vagas = await _candidaturaController.minhasCandidaturas();
      vagasCandidatadas = vagas.toSet();
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar candidaturas: $e");
    }
  }

  // Verifica se o usuário já se candidatou a uma vaga
  bool jaSeCandidatou(String vagaId) {
    return vagasCandidatadas.contains(vagaId);
  }
}