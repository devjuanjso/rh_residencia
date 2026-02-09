import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) _buildLoadingOverlay(),
      ],
    );
  }

  // Overlay de carregamento com fundo semitransparente
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSpinner(),
            _buildLoadingMessage(),
          ],
        ),
      ),
    );
  }

  // Indicador de progresso circular
  Widget _buildSpinner() {
    return const CircularProgressIndicator();
  }

  // Mensagem opcional abaixo do spinner
  Widget _buildLoadingMessage() {
    if (message == null) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          message!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}