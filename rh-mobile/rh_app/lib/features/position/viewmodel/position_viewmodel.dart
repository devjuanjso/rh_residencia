import 'package:flutter/material.dart';
import 'package:rh_app/features/position/controller/position_controller.dart';
import 'package:rh_app/features/projects/model/project_model.dart';
import 'package:rh_app/features/projects/controller/projects_controller.dart';

class ProjectViewModel extends ChangeNotifier {
  // ID do projeto selecionado para vincular a vaga
  String? projectId;

  // Controllers dos campos de texto do formulário
  final tituloController = TextEditingController();
  final descricaoController = TextEditingController();
  final habilidadeController = TextEditingController();
  final certificacoesController = TextEditingController();
  final formacaoController = TextEditingController();

  // Listas de requisitos da vaga
  final List<String> habilidadesRequeridas = [];
  final List<String> certificacoesRequeridas = [];
  final List<String> formacaoRequeridas = [];

  // Lista de projetos carregados da API
  List<Project> projetos = [];

  // Flags de carregamento
  bool loading = false;
  bool loadingProjetos = false;

  // Busca projetos no backend
  Future<void> carregarProjetos() async {
    loadingProjetos = true;
    notifyListeners();

    projetos = await ProjectController.buscarProjetos();

    loadingProjetos = false;
    notifyListeners();
  }

  // Define o projeto vinculado à vaga
  void selecionarProjeto(String? id) {
    projectId = id;
    notifyListeners();
  }

  // Adiciona habilidade na lista
  void adicionarHabilidade() {
    final texto = habilidadeController.text.trim();
    if (texto.isEmpty || habilidadesRequeridas.contains(texto)) return;

    habilidadesRequeridas.add(texto);
    habilidadeController.clear();
    notifyListeners();
  }

  // Remove habilidade da lista
  void removerHabilidade(String habilidade) {
    habilidadesRequeridas.remove(habilidade);
    notifyListeners();
  }

  // Adiciona certificação na lista
  void adicionarCertificacao() {
    final texto = certificacoesController.text.trim();
    if (texto.isEmpty || certificacoesRequeridas.contains(texto)) return;

    certificacoesRequeridas.add(texto);
    certificacoesController.clear();
    notifyListeners();
  }

  // Remove certificação da lista
  void removerCertificacao(String certificacao) {
    certificacoesRequeridas.remove(certificacao);
    notifyListeners();
  }

  // Adiciona formação na lista
  void adicionarFormacao() {
    final texto = formacaoController.text.trim();
    if (texto.isEmpty || formacaoRequeridas.contains(texto)) return;

    formacaoRequeridas.add(texto);
    formacaoController.clear();
    notifyListeners();
  }

  // Remove formação da lista
  void removerFormacao(String formacao) {
    formacaoRequeridas.remove(formacao);
    notifyListeners();
  }

  // Cria a vaga chamando a API
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

    // Feedback visual ao usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso ? 'Vaga criada com sucesso' : 'Erro ao criar vaga',
        ),
      ),
    );
  }

  // Libera memória dos controllers
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
