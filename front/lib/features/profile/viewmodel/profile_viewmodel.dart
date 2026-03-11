import 'package:flutter/material.dart';
import '../model/profile_model.dart';
import '../service/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  ProfileModel? _profile;
  bool _isLoading = false;

  // Controllers para entrada de habilidades e certificações
  final TextEditingController habilidadeController = TextEditingController();
  final TextEditingController certificacaoController = TextEditingController();

  // Listas editáveis
  final List<String> _habilidades = [];
  final List<String> _certificacoes = [];

  // Choices vindos da API
  List<Map<String, dynamic>> cargos = [];
  List<Map<String, dynamic>> senioridades = [];
  List<Map<String, dynamic>> areas = [];

  // Getters públicos
  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;

  List<String> get habilidades => _habilidades;
  List<String> get certificacoes => _certificacoes;

  // Carrega o perfil do usuário da API
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.getProfile();
      _profile = ProfileModel.fromJson(data);

      initForm(_profile!);
    } catch (e) {
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Carrega as opções de cargo, senioridade e área
  Future<void> loadChoices() async {
    try {
      final data = await _service.getChoices();

      cargos = List<Map<String, dynamic>>.from(data["cargos"] ?? []);
      senioridades = List<Map<String, dynamic>>.from(data["senioridades"] ?? []);
      areas = List<Map<String, dynamic>>.from(data["areas"] ?? []);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Inicializa listas do formulário com dados do perfil
  void initForm(ProfileModel profile) {
    _habilidades
      ..clear()
      ..addAll(profile.habilidades);

    _certificacoes
      ..clear()
      ..addAll(profile.certificacoes);

    notifyListeners();
  }

  // Adiciona uma habilidade
  void addHabilidade() {
    final value = habilidadeController.text.trim();

    if (value.isEmpty || _habilidades.contains(value)) return;

    _habilidades.add(value);
    habilidadeController.clear();

    notifyListeners();
  }

  // Remove uma habilidade
  void removeHabilidade(String value) {
    _habilidades.remove(value);
    notifyListeners();
  }

  // Adiciona uma certificação
  void addCertificacao() {
    final value = certificacaoController.text.trim();

    if (value.isEmpty || _certificacoes.contains(value)) return;

    _certificacoes.add(value);
    certificacaoController.clear();

    notifyListeners();
  }

  // Remove uma certificação
  void removeCertificacao(String value) {
    _certificacoes.remove(value);
    notifyListeners();
  }

  // Envia atualização do perfil para a API
  Future<void> updateProfile({
    required String cargo,
    required String senioridade,
    required String area,
    required String formacao,
    required String bio,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.updateProfile({
        "cargo": cargo,
        "senioridade": senioridade,
        "area": area,
        "formacao": formacao,
        "bio": bio,
        "habilidades": _habilidades,
        "certificacoes": _certificacoes,
      });

      await loadProfile();
    } catch (e) {
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Libera os controllers ao destruir o ViewModel
  @override
  void dispose() {
    habilidadeController.dispose();
    certificacaoController.dispose();
    super.dispose();
  }
}