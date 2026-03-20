import 'package:flutter/material.dart';
import '../controller/position_controller.dart';
import '../../projects/controller/project_controller.dart';
import '../model/position_model.dart';

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

  String? _senioridade;
  bool _loading = false;

  String? get projetoId => _projetoId;
  String? get projetoNome => _projetoNome;
  bool get loading => _loading;
  bool get projetoFixo => _projetoFixo;
  String? get senioridade => _senioridade;

  TextEditingController get tituloController => _tituloController;
  TextEditingController get descricaoController => _descricaoController;
  TextEditingController get habilidadeController => _habilidadeController;
  TextEditingController get certificacoesController => _certificacoesController;
  TextEditingController get formacaoController => _formacaoController;

  List<String> get habilidadesRequeridas => _habilidadesRequeridas;
  List<String> get certificacoesRequeridas => _certificacoesRequeridas;

  // Opções de senioridade espelhando o Django
  static const senioridadeOpcoes = [
    DropdownMenuItem(value: 'estagio',      child: Text('Estágio')),
    DropdownMenuItem(value: 'junior',       child: Text('Júnior')),
    DropdownMenuItem(value: 'pleno',        child: Text('Pleno')),
    DropdownMenuItem(value: 'senior',       child: Text('Sênior')),
    DropdownMenuItem(value: 'especialista', child: Text('Especialista')),
  ];

  void setSenioridade(String? value) {
    _senioridade = value;
    notifyListeners();
  }

  void setProjetoFixo(String projetoId) {
    _projetoId = projetoId;
    _projetoFixo = true;
    notifyListeners();
  }

  Future<void> carregarProjetoParaDisplay(
      String projetoId, String? projetoNome) async {
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

  void adicionarHabilidade() {
    final value = _habilidadeController.text.trim();
    if (value.isEmpty || _habilidadesRequeridas.contains(value)) return;
    _habilidadesRequeridas.add(value);
    _habilidadeController.clear();
    notifyListeners();
  }

  void removerHabilidade(String value) {
    _habilidadesRequeridas.remove(value);
    notifyListeners();
  }

  void adicionarCertificacao() {
    final value = _certificacoesController.text.trim();
    if (value.isEmpty || _certificacoesRequeridas.contains(value)) return;
    _certificacoesRequeridas.add(value);
    _certificacoesController.clear();
    notifyListeners();
  }

  void removerCertificacao(String value) {
    _certificacoesRequeridas.remove(value);
    notifyListeners();
  }

  void preencherFormulario({
    required String id,
    required String titulo,
    required String descricao,
    required String projectId,
    required List<String> habilidades,
    required List<String> certificacoes,
    String? formacao,
    String? senioridade,
  }) {
    _positionId = id;

    if (!_projetoFixo) {
      _projetoId = projectId;
    }

    _tituloController.text = titulo;
    _descricaoController.text = descricao;
    _formacaoController.text = formacao ?? '';
    _senioridade = senioridade;

    _habilidadesRequeridas
      ..clear()
      ..addAll(habilidades);

    _certificacoesRequeridas
      ..clear()
      ..addAll(certificacoes);

    notifyListeners();
  }

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
        senioridade: vaga.senioridade,
      );
    }
  }

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
          senioridade: _senioridade,
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
          senioridade: _senioridade,
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

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  void _limparFormulario() {
    _positionId = null;
    if (!_projetoFixo) _projetoId = null;

    _tituloController.clear();
    _descricaoController.clear();
    _habilidadeController.clear();
    _certificacoesController.clear();
    _formacaoController.clear();

    _habilidadesRequeridas.clear();
    _certificacoesRequeridas.clear();
    _senioridade = null;
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