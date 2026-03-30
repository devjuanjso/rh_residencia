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
  final _habilidadeController = TextEditingController();
  final _certificacoesController = TextEditingController();
  final _formacaoController = TextEditingController();

  final List<String> _habilidadesRequeridas = [];
  final List<String> _certificacoesRequeridas = [];

  String? _senioridade;
  String? _area;
  bool _loading = false;

  List<ChoiceOption> _senioridadeOpcoes = [];
  List<ChoiceOption> _areaOpcoes = [];
  bool _loadingChoices = false;

  String? get projetoId => _projetoId;
  String? get projetoNome => _projetoNome;
  bool get loading => _loading;
  bool get projetoFixo => _projetoFixo;
  bool get loadingChoices => _loadingChoices;
  String? get senioridade => _senioridade;
  String? get area => _area;
  List<ChoiceOption> get senioridadeOpcoes => _senioridadeOpcoes;
  List<ChoiceOption> get areaOpcoes => _areaOpcoes;

  TextEditingController get tituloController => _tituloController;
  TextEditingController get habilidadeController => _habilidadeController;
  TextEditingController get certificacoesController => _certificacoesController;
  TextEditingController get formacaoController => _formacaoController;

  List<String> get habilidadesRequeridas => _habilidadesRequeridas;
  List<String> get certificacoesRequeridas => _certificacoesRequeridas;

  Future<void> carregarChoices() async {
    _loadingChoices = true;
    notifyListeners();
    try {
      final choices = await PositionController.getChoices();
      _senioridadeOpcoes = choices.senioridades;
      _areaOpcoes = choices.areas;
    } catch (e) {
      debugPrint('Erro ao carregar choices: $e');
    }
    _loadingChoices = false;
    notifyListeners();
  }

  void setSenioridade(String? value) {
    _senioridade = value;
    notifyListeners();
  }

  void setArea(String? value) {
    _area = value;
    notifyListeners();
  }

  void setProjetoFixo(String projetoId) {
    _projetoId = projetoId;
    _projetoFixo = true;
    notifyListeners();
  }

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
    required String projectId,
    required List<String> habilidades,
    required List<String> certificacoes,
    String? formacao,
    String? senioridade,
    String? area,
  }) {
    _positionId = id;
    if (!_projetoFixo) _projetoId = projectId;
    _tituloController.text = titulo;
    _formacaoController.text = formacao ?? '';
    _senioridade = senioridade;
    _area = area;
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
        projectId: vaga.projetoId,
        habilidades: vaga.habilidadesRequeridas,
        certificacoes: vaga.certificacoesRequeridas,
        formacao: vaga.formacaoDesejada,
        senioridade: vaga.senioridade,
        area: vaga.area,
      );
    }
  }

  Future<void> salvarVaga(BuildContext context) async {
    final titulo = _tituloController.text.trim();

    if (_projetoId == null || titulo.isEmpty) {
      _snack(context, 'Preencha todos os campos obrigatórios');
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      if (isEdit) {
        await PositionController.update(
          id: _positionId!,
          projetoId: _projetoId!,
          titulo: titulo,
          senioridade: _senioridade,
          area: _area,
          habilidadesRequeridas: _habilidadesRequeridas,
          certificacoesRequeridas: _certificacoesRequeridas,
          formacaoDesejada: _formacaoController.text.trim().isEmpty
              ? null
              : _formacaoController.text.trim(),
        );
      } else {
        await PositionController.create(
          projetoId: _projetoId!,
          titulo: titulo,
          senioridade: _senioridade,
          area: _area,
          habilidadesRequeridas: _habilidadesRequeridas,
          certificacoesRequeridas: _certificacoesRequeridas,
          formacaoDesejada: _formacaoController.text.trim().isEmpty
              ? null
              : _formacaoController.text.trim(),
        );
      }

      _limparFormulario();
      if (context.mounted) {
        _snack(context, isEdit ? 'Vaga atualizada!' : 'Vaga criada!');
        Navigator.pop(context, true);
      }
    } catch (e, stack) {
      debugPrint('Erro ao salvar vaga: $e');
      debugPrint('Stack: $stack');
      if (context.mounted) _snack(context, 'Erro ao salvar vaga');
    }

    _loading = false;
    notifyListeners();
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _limparFormulario() {
    _positionId = null;
    if (!_projetoFixo) _projetoId = null;
    _tituloController.clear();
    _habilidadeController.clear();
    _certificacoesController.clear();
    _formacaoController.clear();
    _habilidadesRequeridas.clear();
    _certificacoesRequeridas.clear();
    _senioridade = null;
    _area = null;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _habilidadeController.dispose();
    _certificacoesController.dispose();
    _formacaoController.dispose();
    super.dispose();
  }
}