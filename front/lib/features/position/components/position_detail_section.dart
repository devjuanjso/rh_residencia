import 'package:flutter/material.dart';
import '../model/position_model.dart';
import '../../../core/components/custom_card.dart';

class PositionDetailSection extends StatelessWidget {
  final Position position;
  final bool showTitle;

  const PositionDetailSection({
    super.key,
    required this.position,
    this.showTitle = true,
  });

  Widget _buildSection({
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildTextContent(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        height: 1.5,
      ),
    );
  }

  Widget _buildChipList(List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map(
            (item) => Chip(
              label: Text(item),
              backgroundColor: Colors.blue.shade50,
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título principal
          if (showTitle)
            Text(
              position.titulo,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          
          if (showTitle) const SizedBox(height: 16),

          // Descrição
          if (position.descricao != null && position.descricao!.isNotEmpty)
            Column(
              children: [
                _buildSection(
                  title: 'Descrição',
                  content: _buildTextContent(position.descricao!),
                ),
                const SizedBox(height: 20),
              ],
            ),

          // Formação Desejada
          if (position.formacaoDesejada != null &&
              position.formacaoDesejada!.isNotEmpty)
            Column(
              children: [
                _buildSection(
                  title: 'Formação Desejada',
                  content: _buildTextContent(position.formacaoDesejada!),
                ),
                const SizedBox(height: 20),
              ],
            ),

          // Habilidades Requeridas
          if (position.habilidadesRequeridas.isNotEmpty)
            Column(
              children: [
                _buildSection(
                  title: 'Habilidades Requeridas',
                  content: _buildChipList(position.habilidadesRequeridas),
                ),
                const SizedBox(height: 20),
              ],
            ),

          // Certificações Requeridas
          if (position.certificacoesRequeridas.isNotEmpty)
            Column(
              children: [
                _buildSection(
                  title: 'Certificações Requeridas',
                  content: _buildChipList(position.certificacoesRequeridas),
                ),
                const SizedBox(height: 20),
              ],
            ),
        ],
      ),
    );
  }
}