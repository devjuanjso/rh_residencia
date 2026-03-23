import 'dart:io';
import 'package:flutter/material.dart';
import '../controller/project_controller.dart';

class ProjectFormViewModel extends ChangeNotifier {
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();

  File? imagem;
  bool loading = false;
  String? projetoId;
  bool manterImagemAtual = false;
  String? imagemUrlAtual;
  bool dadosCarregados = false;

  String? tipo;
  DateTime? dataInicio;

  List<Map<String, String>> tiposDisponiveis = [];

  // Busca tipos de projeto da API
  Future<void> carregarChoices() async {
    final choices = await ProjectController.buscarChoices();
    tiposDisponiveis = choices["tipos"] ?? [];
    _safeNotifyListeners();
  }

  // Preenche o formulário com dados de um projeto existente
  void carregarProjetoParaEdicao({
    required String id,
    required String nome,
    required String descricao,
    String? imagemUrl,
    String? tipo,
    DateTime? dataInicio,
  }) {
    projetoId = id;
    nomeController.text = nome;
    descricaoController.text = descricao;
    imagemUrlAtual = imagemUrl;
    manterImagemAtual = true;
    dadosCarregados = true;
    this.tipo = tipo;
    this.dataInicio = dataInicio;
    _safeNotifyListeners();
  }

  // Reseta todos os campos para estado inicial
  void limparDados() {
    nomeController.clear();
    descricaoController.clear();
    imagem = null;
    projetoId = null;
    manterImagemAtual = false;
    imagemUrlAtual = null;
    dadosCarregados = false;
    tipo = null;
    dataInicio = null;
    _safeNotifyListeners();
  }

  // Atualiza imagem selecionada e descarta manter atual
  void setImagem(File? file) {
    imagem = file;
    manterImagemAtual = false;
    _safeNotifyListeners();
  }

  // Alterna entre manter imagem atual ou remover
  void setManterImagemAtual(bool value) {
    manterImagemAtual = value;
    if (value) imagem = null;
    _safeNotifyListeners();
  }

  // Atualiza tipo selecionado
  void setTipo(String? value) {
    tipo = value;
    _safeNotifyListeners();
  }

  // Atualiza data de início selecionada
  void setDataInicio(DateTime? value) {
    dataInicio = value;
    _safeNotifyListeners();
  }

  // Cria ou edita projeto conforme projetoId existir
  Future<String?> salvarProjeto(BuildContext context) async {
    loading = true;
    _safeNotifyListeners();

    try {
      String? projetoIdCriado;

      if (projetoId != null) {
        final sucesso = await ProjectController.editarProjeto(
          projetoId: projetoId!,
          nome: nomeController.text.trim(),
          descricao: descricaoController.text.trim(),
          imagem: imagem,
          manterImagemAtual: manterImagemAtual,
          tipo: tipo,
          dataInicio: dataInicio,
        );

        if (sucesso) projetoIdCriado = projetoId;
      } else {
        projetoIdCriado = await ProjectController.criarProjeto(
          nome: nomeController.text.trim(),
          descricao: descricaoController.text.trim(),
          imagem: imagem,
          tipo: tipo,
          dataInicio: dataInicio,
        );
      }

      loading = false;
      _safeNotifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            projetoIdCriado != null
                ? (projetoId != null ? 'Projeto atualizado com sucesso' : 'Projeto criado com sucesso')
                : (projetoId != null ? 'Erro ao atualizar projeto' : 'Erro ao criar projeto'),
          ),
          backgroundColor: projetoIdCriado != null ? Colors.green : Colors.red,
        ),
      );

      return projetoIdCriado;
    } catch (e) {
      loading = false;
      _safeNotifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );

      return null;
    }
  }

  // Envia PATCH com campos alterados sem feedback de UI
  Future<bool> atualizarProjetoParcial() async {
    if (projetoId == null) return false;

    loading = true;
    _safeNotifyListeners();

    try {
      final sucesso = await ProjectController.atualizarProjetoParcial(
        projetoId: projetoId!,
        nome: nomeController.text.trim(),
        descricao: descricaoController.text.trim(),
        imagem: imagem,
        tipo: tipo,
        dataInicio: dataInicio,
      );

      loading = false;
      _safeNotifyListeners();
      return sucesso;
    } catch (e) {
      loading = false;
      _safeNotifyListeners();
      return false;
    }
  }

  // Busca projeto por ID e carrega no formulário
  Future<void> buscarProjetoParaEdicao(String id) async {
    loading = true;
    _safeNotifyListeners();

    try {
      final projeto = await ProjectController.buscarProjetoPorId(id);

      if (projeto != null) {
        carregarProjetoParaEdicao(
          id: projeto.id,
          nome: projeto.nome,
          descricao: projeto.descricao,
          imagemUrl: projeto.imagem,
          tipo: projeto.tipo,
          dataInicio: projeto.dataInicio,
        );
      } else {
        limparDados();
      }
    } catch (e) {
      limparDados();
    } finally {
      loading = false;
      _safeNotifyListeners();
    }
  }

  // Verdadeiro se há algum campo preenchido
  bool get hasChanges =>
      nomeController.text.isNotEmpty ||
      descricaoController.text.isNotEmpty ||
      imagem != null ||
      manterImagemAtual != true;

  // Verdadeiro se campos obrigatórios estão preenchidos
  bool get isValid =>
      nomeController.text.trim().isNotEmpty &&
      descricaoController.text.trim().isNotEmpty;

  // Título dinâmico conforme modo criação ou edição
  String get screenTitle => projetoId != null ? 'Editar Projeto' : 'Novo Projeto';

  // Texto do botão conforme modo criação ou edição
  String get actionButtonText => projetoId != null ? 'Atualizar' : 'Criar';

  // Descarta controllers ao sair da tela
  void disposeControllers() {
    nomeController.dispose();
    descricaoController.dispose();
  }

  // Notifica listeners apenas se houver algum inscrito
  void _safeNotifyListeners() {
    if (hasListeners) notifyListeners();
  }
}