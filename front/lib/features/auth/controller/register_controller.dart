import 'package:front/features/auth/viewmodel/auth_viewmodel.dart';

class RegisterController {
  final AuthViewModel viewModel;

  RegisterController(this.viewModel);

  Future<void> handleRegister({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    await viewModel.register(
      username: username,
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: role,
    );
  }
}
