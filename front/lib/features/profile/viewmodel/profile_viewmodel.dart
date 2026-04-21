import 'package:flutter/material.dart';
import '../model/profile_model.dart';
import '../service/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  ProfileModel? _profile;
  bool _isLoading = false;

  final TextEditingController habilidadeController = TextEditingController();
  final TextEditingController certificacaoController = TextEditingController();

  final List<String> _habilidades = [];
  final List<String> _certificacoes = [];

  List<Map<String, dynamic>> cargos = [];
  List<Map<String, dynamic>> senioridades = [];
  List<Map<String, dynamic>> areas = [];

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  List<String> get habilidades => _habilidades;
  List<String> get certificacoes => _certificacoes;

  Future<void> loadProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _service.getProfile();
      _profile = ProfileModel.fromJson(data);
      initForm(_profile!);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  void initForm(ProfileModel profile) {
    _habilidades..clear()..addAll(profile.habilidades);
    _certificacoes..clear()..addAll(profile.certificacoes);
    notifyListeners();
  }

  void addHabilidade() {
    final value = habilidadeController.text.trim();
    if (value.isEmpty || _habilidades.contains(value)) return;
    _habilidades.add(value);
    habilidadeController.clear();
    notifyListeners();
  }

  void removeHabilidade(String value) {
    _habilidades.remove(value);
    notifyListeners();
  }

  void addCertificacao() {
    final value = certificacaoController.text.trim();
    if (value.isEmpty || _certificacoes.contains(value)) return;
    _certificacoes.add(value);
    certificacaoController.clear();
    notifyListeners();
  }

  void removeCertificacao(String value) {
    _certificacoes.remove(value);
    notifyListeners();
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String cargo,
    required String senioridade,
    required String area,
    required String bio,
    required String linkedin,
    required String formacao,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateProfile({
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "cargo": cargo,
        "senioridade": senioridade,
        "area": area,
        "bio": bio,
        "linkedin": linkedin,
        "formacao": formacao,
        "habilidades": _habilidades,
        "certificacoes": _certificacoes,
      });
      await loadProfile();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mescla habilidades e certificações extraídas do currículo sem duplicar existentes.
  void importarDoCurriculo(Map<String, dynamic> dados) {
    final habilidades = List<String>.from(dados['habilidades'] ?? []);
    for (final h in habilidades) {
      if (h.isNotEmpty && !_habilidades.contains(h)) _habilidades.add(h);
    }

    final certs = List<String>.from(dados['certificacoes'] ?? []);
    for (final c in certs) {
      if (c.isNotEmpty && !_certificacoes.contains(c)) _certificacoes.add(c);
    }

    notifyListeners();
  }

  @override
  void dispose() {
    habilidadeController.dispose();
    certificacaoController.dispose();
    super.dispose();
  }
}