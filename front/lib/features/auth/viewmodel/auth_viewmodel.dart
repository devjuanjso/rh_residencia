import 'package:flutter/material.dart';
import 'package:front/features/auth/model/user_model.dart';
import 'package:front/features/auth/service/auth_service.dart';
import 'package:front/core/services/secure_storage_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final SecureStorageService _storage = SecureStorageService();

  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  // Retorna verdadeiro se houver usuário autenticado em memória
  bool get isAuthenticated => _user != null;

  // Realiza login na API, salva token localmente e atualiza estado
  Future<void> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _authService.login(username, password);
      final token = data["access"];

      // Salva token de forma segura no dispositivo
      await _storage.saveToken(token);

      // Atualiza usuário em memória
      _user = UserModel(
        id: "",
        username: username,
        email: "",
        role: "",
        accessToken: token,
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Carrega token salvo ao iniciar o app e restaura sessão
  Future<void> loadUserFromStorage() async {
    final token = await _storage.getToken();

    if (token != null) {
      _user = UserModel(
        id: "",
        username: "",
        email: "",
        role: "",
        accessToken: token,
      );

      notifyListeners();
    }
  }

  // Remove token salvo e limpa usuário da memória
  Future<void> logout() async {
    await _storage.deleteToken();
    _user = null;
    notifyListeners();
  }
}