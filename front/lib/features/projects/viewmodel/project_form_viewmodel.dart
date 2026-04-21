import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/services/ai_controller.dart';
import '../../position/controller/position_controller.dart';
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

  // IA: sugestão gerada a partir de PDF
  bool loadingIA = false;
  List<Map<String, dynamic>> vagasSugeridas = [];
  final Set<int> vagasSelecionadas = {}; // índices selecionados
  String? erroIA;

  Future<void> carregarChoices() async {
    final choices = await ProjectController.buscarChoices();
    tiposDisponiveis = choices["tipos"] ?? [];
    _safeNotifyListeners();
  }

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

  void setImagem(File? file) {
    imagem = file;
    manterImagemAtual = false;
    _safeNotifyListeners();
  }

  void setManterImagemAtual(bool value) {
    manterImagemAtual = value;
    if (value) imagem = null;
    _safeNotifyListeners();
  }

  void setTipo(String? value) {
    tipo = value;
    _safeNotifyListeners();
  }

  void setDataInicio(DateTime? value) {
    dataInicio = value;
    _safeNotifyListeners();
  }

  /// Envia texto ao backend, preenche o formulário e armazena vagas sugeridas.
  Future<void> importarDeTexto(String descricao) async {
    loadingIA = true;
    erroIA = null;
    _safeNotifyListeners();

    final result = await AiController.sugerirProjetoPorTexto(descricao);

    if (result.erro != null) {
      erroIA = result.erro;
      loadingIA = false;
      _safeNotifyListeners();
      return;
    }

    _aplicarDadosIA(result.dados!);
  }

  /// Envia PDF ao backend, preenche o formulário e armazena vagas sugeridas.
  Future<void> importarDePdf(File arquivo) async {
    loadingIA = true;
    erroIA = null;
    _safeNotifyListeners();

    final result = await AiController.sugerirProjetoPorPdf(arquivo);

    if (result.erro != null) {
      erroIA = result.erro;
      loadingIA = false;
      _safeNotifyListeners();
      return;
    }

    _aplicarDadosIA(result.dados!);
  }

  void _aplicarDadosIA(Map<String, dynamic> dados) {
    if (dados['nome'] != null) nomeController.text = dados['nome'].toString();
    if (dados['descricao'] != null) descricaoController.text = dados['descricao'].toString();
    if (dados['tipo'] != null) tipo = dados['tipo'].toString();

    vagasSugeridas = List<Map<String, dynamic>>.from(dados['vagas_sugeridas'] ?? []);
    vagasSelecionadas
      ..clear()
      ..addAll(List.generate(vagasSugeridas.length, (i) => i));

    loadingIA = false;
    _safeNotifyListeners();
  }

  void toggleVagaSugerida(int index) {
    if (vagasSelecionadas.contains(index)) {
      vagasSelecionadas.remove(index);
    } else {
      vagasSelecionadas.add(index);
    }
    _safeNotifyListeners();
  }

  void limparSugestaoIA() {
    vagasSugeridas = [];
    vagasSelecionadas.clear();
    erroIA = null;
    _safeNotifyListeners();
  }

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

          if (projetoIdCriado != null && projetoId == null && vagasSelecionadas.isNotEmpty) {
        for (final idx in vagasSelecionadas) {
          if (idx < vagasSugeridas.length) {
            final v = vagasSugeridas[idx];
            try {
              await PositionController.create(
                projetoId: projetoIdCriado,
                titulo: v['titulo']?.toString() ?? 'Vaga',
                senioridade: v['senioridade']?.toString(),
                area: v['area']?.toString(),
                habilidadesRequeridas: List<String>.from(v['habilidades_requeridas'] ?? []),
                certificacoesRequeridas: const [],
                formacaoDesejada: v['formacao_desejada']?.toString(),
              );
            } catch (_) {}
          }
        }
      }

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

  bool get hasChanges =>
      nomeController.text.isNotEmpty ||
      descricaoController.text.isNotEmpty ||
      imagem != null ||
      manterImagemAtual != true;

  bool get isValid =>
      nomeController.text.trim().isNotEmpty &&
      descricaoController.text.trim().isNotEmpty;

  String get screenTitle => projetoId != null ? 'Editar Projeto' : 'Novo Projeto';

  String get actionButtonText => projetoId != null ? 'Atualizar' : 'Criar';

  void disposeControllers() {
    nomeController.dispose();
    descricaoController.dispose();
  }

  void _safeNotifyListeners() {
    if (hasListeners) notifyListeners();
  }
}