import 'package:flutter/material.dart';
import 'package:rh_app/features/position/controller/position_controller.dart';
import 'package:rh_app/features/projects/controller/project_controller.dart';
import 'package:rh_app/features/position/model/position_model.dart';

class PositionFormViewModel extends ChangeNotifier {
  String? _positionId;
  bool get isEdit => _positionId != null;

  String? _projetoId;
  String? _projetoNome;
  bool _projetoFixo = false;
  
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _habilidadeController = TextEditingController();
  final _certificacoesController = TextEditingController();
  final _formacaoController = TextEditingController();

  final List<String> _habilidadesRequeridas = [];
  final List<String> _certificacoesRequeridas = [];

  bool _loading = false;

  String? get projetoId => _projetoId;
  String? get projetoNome => _projetoNome;
  bool get loading => _loading;
  bool get projetoFixo => _projetoFixo;

  TextEditingController get tituloController => _tituloController;
  TextEditingController get descricaoController => _descricaoController;
  TextEditingController get habilidadeController => _habilidadeController;
  TextEditingController get certificacoesController => _certificacoesController;
  TextEditingController get formacaoController => _formacaoController;

  List<String> get habilidadesRequeridas => _habilidadesRequeridas;
  List<String> get certificacoesRequeridas => _certificacoesRequeridas;

  // Define um projeto fixo (não pode ser alterado)
  void setProjetoFixo(String projetoId) {
    _projetoId = projetoId;
    _projetoFixo = true;
    notifyListeners();
  }

  // Carrega o nome do projeto para display
  Future<void> carregarProjetoParaDisplay(String projetoId, String? projetoNome) async {
    if (projetoNome != null) {
      _projetoNome = projetoNome;
      notifyListeners();
      return;
    }
    
    try {
      final projeto = await ProjectController.buscarProjetoPorId(projetoId);
      _projetoNome = projeto?.nome ?? 'Projeto não encontrado';
    } catch (_) {
      _projetoNome = 'Erro ao carregar projeto';
    }
    notifyListeners();
  }

  // Adiciona uma nova habilidade à lista de habilidades requeridas
  void adicionarHabilidade() {
    final value = _habilidadeController.text.trim();
    if (value.isEmpty || _habilidadesRequeridas.contains(value)) return;

    _habilidadesRequeridas.add(value);
    _habilidadeController.clear();
    notifyListeners();
  }

  // Remove uma habilidade específica da lista de habilidades requeridas
  void removerHabilidade(String value) {
    _habilidadesRequeridas.remove(value);
    notifyListeners();
  }

  // Adiciona uma nova certificação à lista de certificações requeridas
  void adicionarCertificacao() {
    final value = _certificacoesController.text.trim();
    if (value.isEmpty || _certificacoesRequeridas.contains(value)) return;

    _certificacoesRequeridas.add(value);
    _certificacoesController.clear();
    notifyListeners();
  }

  // Remove uma certificação específica da lista de certificações requeridas
  void removerCertificacao(String value) {
    _certificacoesRequeridas.remove(value);
    notifyListeners();
  }

  // Preenche o formulário com os dados de uma vaga existente para edição
  void preencherFormulario({
    required String id,
    required String titulo,
    required String descricao,
    required String projectId,
    required List<String> habilidades,
    required List<String> certificacoes,
    String? formacao,
  }) {
    _positionId = id;
    
    // Só define o projeto se não estiver fixo (para edição)
    if (!_projetoFixo) {
      _projetoId = projectId;
    }

    _tituloController.text = titulo;
    _descricaoController.text = descricao;
    _formacaoController.text = formacao ?? '';

    _habilidadesRequeridas
      ..clear()
      ..addAll(habilidades);

    _certificacoesRequeridas
      ..clear()
      ..addAll(certificacoes);

    notifyListeners();
  }

  // Carrega os dados de uma vaga existente para modo de edição
  void carregarParaEdicao(Position? vaga) {
    if (vaga != null) {
      preencherFormulario(
        id: vaga.id,
        titulo: vaga.titulo,
        descricao: vaga.descricao ?? '',
        projectId: vaga.projetoId,
        habilidades: vaga.habilidadesRequeridas,
        certificacoes: vaga.certificacoesRequeridas,
        formacao: vaga.formacaoDesejada,
      );
    }
  }

  // Salva uma nova vaga ou atualiza uma existente
  Future<void> salvarVaga(BuildContext context) async {
    if (_projetoId == null ||
        _tituloController.text.isEmpty ||
        _descricaoController.text.isEmpty) {
      _snack(context, 'Preencha os campos obrigatórios');
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      if (isEdit) {
        await PositionController.update(
          id: _positionId!,
          projetoId: _projetoId!,
          titulo: _tituloController.text,
          descricao: _descricaoController.text,
          habilidadesRequeridas: _habilidadesRequeridas,
          certificacoesRequeridas: _certificacoesRequeridas,
          formacaoDesejada: _formacaoController.text.isEmpty
              ? null
              : _formacaoController.text,
        );
      } else {
        await PositionController.create(
          projetoId: _projetoId!,
          titulo: _tituloController.text,
          descricao: _descricaoController.text,
          habilidadesRequeridas: _habilidadesRequeridas,
          certificacoesRequeridas: _certificacoesRequeridas,
          formacaoDesejada: _formacaoController.text.isEmpty
              ? null
              : _formacaoController.text,
        );
      }

      _limparFormulario();
      _snack(context, isEdit ? 'Vaga atualizada' : 'Vaga criada');
      Navigator.pop(context, true);
    } catch (_) {
      _snack(context, 'Erro ao salvar vaga');
    }

    _loading = false;
    notifyListeners();
  }

  // Exibe uma mensagem de snackbar na tela
  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // Limpa todos os campos do formulário
  void _limparFormulario() {
    _positionId = null;
    if (!_projetoFixo) {
      _projetoId = null;
    }

    _tituloController.clear();
    _descricaoController.clear();
    _habilidadeController.clear();
    _certificacoesController.clear();
    _formacaoController.clear();

    _habilidadesRequeridas.clear();
    _certificacoesRequeridas.clear();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _habilidadeController.dispose();
    _certificacoesController.dispose();
    _formacaoController.dispose();
    super.dispose();
  }
}