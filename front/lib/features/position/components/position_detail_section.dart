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

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            _buildTitleRow(),
            const SizedBox(height: 16),
          ],
          if (position.formacaoDesejada != null &&
              position.formacaoDesejada!.isNotEmpty) ...[
            _buildSection(
              title: 'Formação Desejada',
              content: _buildTextContent(position.formacaoDesejada!),
            ),
            const SizedBox(height: 20),
          ],
          if (position.habilidadesRequeridas.isNotEmpty) ...[
            _buildSection(
              title: 'Habilidades Requeridas',
              content: _buildChipList(position.habilidadesRequeridas),
            ),
            const SizedBox(height: 20),
          ],
          if (position.certificacoesRequeridas.isNotEmpty) ...[
            _buildSection(
              title: 'Certificações Requeridas',
              content: _buildChipList(position.certificacoesRequeridas),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            position.titulo,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (position.senioridade != null) ...[
          const SizedBox(width: 10),
          _buildSenioridadeBadge(position.senioridade!),
        ],
      ],
    );
  }

  Widget _buildSenioridadeBadge(String senioridade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        senioridade,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildTextContent(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, height: 1.5),
    );
  }

  Widget _buildChipList(List<String> items) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items
          .map((item) => Chip(
                label: Text(item),
                backgroundColor: Colors.blue.shade50,
              ))
          .toList(),
    );
  }
}