import 'package:flutter/material.dart';
import 'package:rh_app/features/position/controller/position_controller.dart';
import 'package:rh_app/features/projects/model/project_model.dart';
import 'package:rh_app/features/projects/controller/projects_controller.dart';

class ProjectViewModel extends ChangeNotifier {
  String? projectId;

  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  final habilidadeController = TextEditingController();
    final List<String> habilidadesRequeridas = [];
  final certificacoesController = TextEditingController();
    final List<String> certificacoesRequeridas = [];
  final formacaoController = TextEditingController();
    final List<String> formacaoRequeridas = [];

  List<Project> projetos = [];
  bool loading = false;
  bool loadingProjetos = false;

  Future<void> carregarProjetos() async {
    loadingProjetos = true;
    notifyListeners();

    projetos = await ProjectController.buscarProjetos();

    loadingProjetos = false;
    notifyListeners();
  }

  void selecionarProjeto(String? id) {
    projectId = id;
    notifyListeners();
  }

  void adicionarHabilidade() {
    final texto = habilidadeController.text.trim();
    if (texto.isEmpty || habilidadesRequeridas.contains(texto)) return;

    habilidadesRequeridas.add(texto);
    habilidadeController.clear();
    notifyListeners();
  }

  void removerHabilidade(String habilidade) {
    habilidadesRequeridas.remove(habilidade);
    notifyListeners();
  }

  Future<void> salvarVaga(BuildContext context) async {
    if (projectId == null) return;

    loading = true;
    notifyListeners();

    final sucesso = await PositionController.criarVaga(
      titulo: tituloController.text.trim(),
      descricao: descricaoController.text.trim(),
      projectId: projectId!,
      habilidadesRequeridas: habilidadesRequeridas,
      certificacoesRequeridas: certificacoesRequeridas,
      formacaoDesejada: formacaoRequeridas,
    );

    loading = false;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso ? 'Vaga criada com sucesso' : 'Erro ao criar vaga',
        ),
      ),
    );
  }

  @override
  void dispose() {
    tituloController.dispose();
    descricaoController.dispose();
    habilidadeController.dispose();
    certificacoesController.dispose();
    formacaoController.dispose();
    super.dispose();
  }
}
