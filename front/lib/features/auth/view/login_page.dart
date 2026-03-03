import 'package:flutter/material.dart';
import 'package:front/features/auth/controller/auth_controller.dart';
import 'package:front/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Pegando o AuthViewModel do Provider
    final viewModel = context.watch<AuthViewModel>();
    final controller = LoginController(viewModel);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Login", style: TextStyle(fontSize: 24)),

              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: "Usuário"),
              ),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Senha"),
              ),

              const SizedBox(height: 20),

              viewModel.isLoading
                  ? const CircularProgressIndicator() // mostra carregando
                  : ElevatedButton(
                      onPressed: () async {
                        await controller.handleLogin(
                          usernameController.text,
                          passwordController.text,
                        );

                        // Apenas navega se autenticado com sucesso
                        if (viewModel.isAuthenticated) {
                          Navigator.pushReplacementNamed(context, "/home");
                        }
                      },
                      child: const Text("Entrar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}