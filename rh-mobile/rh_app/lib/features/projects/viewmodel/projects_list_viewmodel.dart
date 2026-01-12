import 'package:flutter/material.dart';
import 'package:rh_app/features/position/model/position_model.dart';
import 'package:rh_app/features/projects/controller/projects_controller.dart';
import 'package:rh_app/features/projects/model/project_model.dart';

class ProjectListViewModel extends ChangeNotifier {
  List<Project> projetos = [];
  List<Position> vagasDoProjeto = [];
  bool loading = false;
  bool loadingVagas = false;
  int projetoAtual = 0;

  // Busca todos os projetos
  Future<void> carregarProjetos() async {
    loading = true;
    notifyListeners();

    projetos = await ProjectController.buscarProjetos();

    loading = false;
    notifyListeners();

    // Se houver projetos, carrega as vagas do primeiro
    if (projetos.isNotEmpty) {
      projetoAtual = 0;
      await carregarVagasDoProjetoAtual();
    }
  }

  // Busca as vagas do projeto selecionado
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
      // Em erro, retorna lista vazia
      vagasDoProjeto = [];
    } finally {
      loadingVagas = false;
      notifyListeners();
    }
  }

  // Define manualmente qual projeto está selecionado
  Future<void> setProjetoAtual(int index) async {
    if (index < 0 || index >= projetos.length) return;
    if (index == projetoAtual) return;

    projetoAtual = index;
    vagasDoProjeto = [];
    notifyListeners();

    await carregarVagasDoProjetoAtual();
  }

  // Avança para o próximo projeto da lista
  Future<void> irParaProximoProjeto() async {
    if (projetos.isEmpty) return;
    if (projetoAtual >= projetos.length - 1) return;

    projetoAtual++;
    vagasDoProjeto = [];
    notifyListeners();

    await carregarVagasDoProjetoAtual();
  }
}
