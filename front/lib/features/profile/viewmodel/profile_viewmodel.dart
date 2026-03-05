import 'package:flutter/material.dart';
import '../model/profile_model.dart';
import '../service/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  ProfileModel? _profile;
  bool _isLoading = false;

  // Controllers usados para digitar habilidades e certificações
  final TextEditingController habilidadeController = TextEditingController();
  final TextEditingController certificacaoController = TextEditingController();

  // Listas internas editáveis
  final List<String> _habilidades = [];
  final List<String> _certificacoes = [];

  // Getters públicos
  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;

  List<String> get habilidades => _habilidades;
  List<String> get certificacoes => _certificacoes;

  /*
  Carrega o perfil do usuário a partir da API
  */
  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.getProfile();
      _profile = ProfileModel.fromJson(data);

      // Inicializa listas editáveis com dados do perfil
      initForm(_profile!);
    } catch (e) {
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  /*
  Inicializa as listas usadas no formulário
  */
  void initForm(ProfileModel profile) {
    _habilidades
      ..clear()
      ..addAll(profile.habilidades);

    _certificacoes
      ..clear()
      ..addAll(profile.certificacoes);

    notifyListeners();
  }

  /*
  Adiciona uma nova habilidade à lista
  */
  void addHabilidade() {
    final value = habilidadeController.text.trim();

    if (value.isEmpty || _habilidades.contains(value)) return;

    _habilidades.add(value);
    habilidadeController.clear();

    notifyListeners();
  }

  /*
  Remove uma habilidade específica
  */
  void removeHabilidade(String value) {
    _habilidades.remove(value);
    notifyListeners();
  }

  /*
  Adiciona uma nova certificação à lista
  */
  void addCertificacao() {
    final value = certificacaoController.text.trim();

    if (value.isEmpty || _certificacoes.contains(value)) return;

    _certificacoes.add(value);
    certificacaoController.clear();

    notifyListeners();
  }

  /*
  Remove uma certificação específica
  */
  void removeCertificacao(String value) {
    _certificacoes.remove(value);
    notifyListeners();
  }

  /*
  Atualiza o perfil do usuário na API
  */
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

      // Recarrega os dados atualizados
      await loadProfile();
    } catch (e) {
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  /*
  Libera os controllers ao destruir o ViewModel
  */
  @override
  void dispose() {
    habilidadeController.dispose();
    certificacaoController.dispose();
    super.dispose();
  }
}