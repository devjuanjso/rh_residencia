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
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Cores Venturus
  static const _bgColor      = Color(0xFF0D0B14);
  static const _surfaceColor = Color(0xFF130F1E);
  static const _borderColor  = Color(0xFF2B2240);
  static const _accentColor  = Color(0xFF7B3FC8);
  static const _accentLight  = Color(0xFF9B5FE8);
  static const _textPrimary  = Color(0xFFF0EAFF);
  static const _textMuted    = Color(0xFF5C5070);
  static const _textHint     = Color(0xFF2E2446);
  static const _labelColor   = Color(0xFF7B6A9A);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final controller = LoginController(viewModel);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 42),
              _buildLogo(),
              const SizedBox(height: 32),
              _buildHeadline(),
              const SizedBox(height: 30),
              _buildField(
                label: 'USUÁRIO',
                controller: _usernameController,
                hint: 'seu@venturus.org.br',
                suffixIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'SENHA',
                controller: _passwordController,
                hint: '••••••••',
                obscure: _obscurePassword,
                suffixIcon: _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                onIconTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 10),
              _buildForgotPassword(),
              const SizedBox(height: 26),
              _buildLoginButton(viewModel, controller, context),
              const SizedBox(height: 32),
              _buildFooter(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        CustomPaint(
          size: const Size(34, 34),
          painter: _HexLogoPainter(),
        ),
        const SizedBox(width: 10),
        const Text(
          'venturus',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFE8DEFF),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildHeadline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Bem-vindo\nde volta.',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: _textPrimary,
            height: 1.25,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Acesse sua conta para continuar.',
          style: TextStyle(
            fontSize: 13,
            color: _textMuted,
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
    required IconData suffixIcon,
    bool obscure = false,
    VoidCallback? onIconTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            letterSpacing: 1.0,
            color: _labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(
            fontSize: 14,
            color: _textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _textHint, fontSize: 14),
            filled: true,
            fillColor: _surfaceColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accentColor, width: 1.5),
            ),
            suffixIcon: GestureDetector(
              onTap: onIconTap,
              child: Icon(suffixIcon, size: 16, color: _textHint),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {},
        child: const Text(
          'Esqueci minha senha',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6645A8),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    AuthViewModel viewModel,
    LoginController controller,
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: viewModel.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: _accentLight,
                strokeWidth: 2,
              ),
            )
          : ElevatedButton(
              onPressed: () async {
                await controller.handleLogin(
                  _usernameController.text,
                  _passwordController.text,
                );
                if (viewModel.isAuthenticated && context.mounted) {
                  Navigator.pushReplacementNamed(context, '/home');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentColor,
                foregroundColor: const Color(0xFFF5EFFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Entrar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, color: Color(0xFF3D3058)),
          children: [
            const TextSpan(text: 'Não tem conta? '),
            WidgetSpan(
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: const Text(
                  'Fale com o RH',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9B6FD4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter do logo hexagonal do Venturus
class _HexLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Hexágono externo
    final outerPath = Path();
    final outerR = size.width / 2 - 1;
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * 3.14159 / 180;
      final x = cx + outerR * cos(angle);
      final y = cy + outerR * sin(angle);
      i == 0 ? outerPath.moveTo(x, y) : outerPath.lineTo(x, y);
    }
    outerPath.close();

    canvas.drawPath(
      outerPath,
      Paint()
        ..color = const Color(0xFF7B3FC8).withOpacity(0.12)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      outerPath,
      Paint()
        ..color = const Color(0xFF7B3FC8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    // Hexágono interno
    final innerPath = Path();
    final innerR = size.width / 3.8;
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * 3.14159 / 180;
      final x = cx + innerR * cos(angle);
      final y = cy + innerR * sin(angle);
      i == 0 ? innerPath.moveTo(x, y) : innerPath.lineTo(x, y);
    }
    innerPath.close();

    canvas.drawPath(
      innerPath,
      Paint()
        ..color = const Color(0xFF9B5FE8).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Ponto central
    canvas.drawCircle(
      Offset(cx, cy),
      2.8,
      Paint()..color = const Color(0xFF9B5FE8),
    );

    // Linhas verticais
    canvas.drawLine(
      Offset(cx, cy - 2.8),
      Offset(cx, cy - outerR + 2),
      Paint()
        ..color = const Color(0xFF7B3FC8).withOpacity(0.35)
        ..strokeWidth = 0.8,
    );
    canvas.drawLine(
      Offset(cx, cy + 2.8),
      Offset(cx, cy + outerR - 2),
      Paint()
        ..color = const Color(0xFF7B3FC8).withOpacity(0.35)
        ..strokeWidth = 0.8,
    );
  }

  double cos(double angle) => _cos(angle);
  double sin(double angle) => _sin(angle);

  double _cos(double r) {
    // Taylor approx — use dart:math em produção
    return _mathCos(r);
  }

  double _sin(double r) {
    return _mathSin(r);
  }

  // chamadas para dart:math
  static double _mathCos(double r) => _dartCos(r);
  static double _mathSin(double r) => _dartSin(r);
  static double _dartCos(double r) {
    // ignore: avoid_returning_null_for_void
    return (r == 0)
        ? 1.0
        : _computeCos(r);
  }

  static double _computeCos(double r) {
    double result = 1, term = 1;
    for (int i = 1; i <= 10; i++) {
      term *= -r * r / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  static double _dartSin(double r) {
    double result = r, term = r;
    for (int i = 1; i <= 10; i++) {
      term *= -r * r / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  @override
  bool shouldRepaint(_HexLogoPainter oldDelegate) => false;
}