import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Instância segura
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = "access_token";

  // Salvar token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Buscar token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Remover token
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}