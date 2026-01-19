import 'package:flutter/material.dart';
import 'package:rh_app/features/position/model/position_model.dart';
import 'package:rh_app/features/projects/controller/project_controller.dart';
import 'package:rh_app/features/projects/model/project_model.dart';

class ProjectListViewModel extends ChangeNotifier {
  List<Project> projetos = [];
  List<Position> vagasDoProjeto = [];
  bool loading = false;
  bool loadingVagas = false;
  bool loadingAdmin = false;
  int projetoAtual = 0;
  List<Project> projetosAdmin = [];

  // Carrega todos os projetos disponíveis na API
  Future<void> carregarProjetos() async {
    loading = true;
    notifyListeners();

    projetos = await ProjectController.buscarProjetos();

    loading = false;
    notifyListeners();

    // Carrega vagas do primeiro projeto automaticamente
    if (projetos.isNotEmpty) {
      projetoAtual = 0;
      await carregarVagasDoProjetoAtual();
    }
  }

  // Busca as vagas associadas ao projeto atualmente selecionado
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
      vagasDoProjeto = []; // Lista vazia em caso de erro
    } finally {
      loadingVagas = false;
      notifyListeners();
    }
  }

  // Altera o projeto selecionado manualmente
  Future<void> setProjetoAtual(int index) async {
    if (index < 0 || index >= projetos.length) return;
    if (index == projetoAtual) return;

    projetoAtual = index;
    vagasDoProjeto = [];
    notifyListeners();

    await carregarVagasDoProjetoAtual();
  }

  // Avança automaticamente para o próximo projeto na lista
  Future<void> irParaProximoProjeto() async {
    if (projetos.isEmpty) return;
    if (projetoAtual >= projetos.length - 1) return;

    projetoAtual++;
    vagasDoProjeto = [];
    notifyListeners();

    await carregarVagasDoProjetoAtual();
  }

  // Carrega projetos para a aba de administração
  Future<void> carregarProjetosAdmin() async {
    loadingAdmin = true;
    notifyListeners();

    try {
      projetosAdmin = await ProjectController.buscarProjetos();
    } catch (e) {
      projetosAdmin = [];
    } finally {
      loadingAdmin = false;
      notifyListeners();
    }
  }

  // Exclui um projeto da lista de administração
  Future<void> excluirProjeto(String id) async {
    final sucesso = await ProjectController.excluirProjeto(id);
    if (sucesso) {
      projetosAdmin.removeWhere((projeto) => projeto.id == id);
      projetos.removeWhere((projeto) => projeto.id == id);
      notifyListeners();
    }
  }
}