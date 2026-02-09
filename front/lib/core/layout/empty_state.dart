import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;

  const EmptyState({
    super.key,
    this.icon = Icons.inbox,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildIcon(),
            const SizedBox(height: 16),
            _buildTitle(),
            _buildDescription(),
            _buildAction(),
          ],
        ),
      ),
    );
  }

  // Ícone ilustrativo do estado vazio
  Widget _buildIcon() {
    return Icon(icon, size: 80, color: Colors.grey);
  }

  // Título principal
  Widget _buildTitle() {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Descrição opcional
  Widget _buildDescription() {
    if (description == null) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          description!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // Botão ou ação opcional
  Widget _buildAction() {
    if (action == null) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 24),
        action!,
      ],
    );
  }
}