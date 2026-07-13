import 'package:flutter/material.dart';
import 'package:front/features/auth/controller/register_controller.dart';
import 'package:front/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:provider/provider.dart';

const _purple = Color(0xFF6B21A8);
const _fieldBorder = Color(0xFFE2E8F0);
const _textPrimary = Color(0xFF1A1A2E);
const _textSecondary = Color(0xFF64748B);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRh = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final controller = RegisterController(vm);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeadline(),
              const SizedBox(height: 28),
              _buildField(
                label: 'Nome',
                controller: _firstNameController,
                hint: 'Seu nome',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Sobrenome',
                controller: _lastNameController,
                hint: 'Seu sobrenome',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Usuário',
                controller: _usernameController,
                hint: 'seu.nome',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'E-mail',
                controller: _emailController,
                hint: 'voce@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'Senha',
                controller: _passwordController,
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 16),
              _buildPasswordField(
                label: 'Confirmar senha',
                controller: _confirmPasswordController,
                obscure: _obscureConfirmPassword,
                onToggle: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              const SizedBox(height: 24),
              _buildRhToggle(),
              const SizedBox(height: 28),
              _buildRegisterButton(vm, controller),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Criar conta',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Preencha os dados para começar.',
          style: TextStyle(
            fontSize: 14,
            color: _textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
            prefixIcon: Icon(icon, size: 18, color: _textSecondary),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _fieldBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _purple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(fontSize: 14, color: _textPrimary),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle:
                const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline_rounded,
                size: 18, color: _textSecondary),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 18,
                color: _textSecondary,
              ),
              onPressed: onToggle,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _fieldBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _purple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRhToggle() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isRh ? const Color(0xFFF5F0FA) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isRh ? _purple.withOpacity(0.4) : _fieldBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings_outlined,
                        size: 20, color: _isRh ? _purple : _textSecondary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Cadastrar como RH',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isRh,
                activeThumbColor: _purple,
                onChanged: (value) => setState(() => _isRh = value),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: Colors.orange),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Atenção: essa opção existe apenas durante a fase de testes '
                  'do sistema. Em produção, o papel de RH não poderá ser '
                  'escolhido livremente no cadastro.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(AuthViewModel vm, RegisterController controller) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: vm.isLoading
            ? Container(
                key: const ValueKey('loading'),
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              )
            : ElevatedButton(
                key: const ValueKey('button'),
                onPressed: () => _handleRegister(vm, controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Criar conta',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _handleRegister(
      AuthViewModel vm, RegisterController controller) async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showMessage('Preencha todos os campos', isError: true);
      return;
    }

    if (password != confirmPassword) {
      _showMessage('As senhas não coincidem', isError: true);
      return;
    }

    try {
      await controller.handleRegister(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        role: _isRh ? 'RH' : 'COLABORADOR',
      );
      // Volta para a rota raiz, que já troca para HomePage
      // automaticamente quando AuthViewModel.isAuthenticated é true.
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceFirst('Exception: ', ''),
            isError: true);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : _purple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
