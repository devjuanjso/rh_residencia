import 'package:front/features/auth/viewmodel/auth_viewmodel.dart';

class LoginController {
  final AuthViewModel viewModel;

  LoginController(this.viewModel);

  Future<void> handleLogin(String username, String password) async {
    await viewModel.login(username, password);
  }
}