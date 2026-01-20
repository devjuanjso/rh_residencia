import 'package:flutter/material.dart';
import 'package:rh_app/features/position/model/position_model.dart';

class PositionListItem extends StatelessWidget {
  final Position position;
  final VoidCallback? onViewDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onApply;
  final bool showActions;
  final bool showEducation;
  final bool showCertifications;

  const PositionListItem({
    super.key,
    required this.position,
    this.onViewDetails,
    this.onEdit,
    this.onDelete,
    this.onApply,
    this.showActions = true,
    this.showEducation = false,
    this.showCertifications = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPositionTitle(),
            _buildPositionDescription(),
            _buildEducationInfo(),
            _buildRequiredSkills(),
            _buildCertifications(),
            _buildActionsRow(),
          ],
        ),
      ),
    );
  }

  // Título da vaga
  Widget _buildPositionTitle() {
    return Text(
      position.titulo,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Descrição da vaga
  Widget _buildPositionDescription() {
    if (position.descricao == null || position.descricao!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        position.descricao!,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  // Informação de formação desejada
  Widget _buildEducationInfo() {
    if (!showEducation || 
        position.formacaoDesejada == null || 
        position.formacaoDesejada!.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildInfoRow(
      icon: Icons.school,
      iconColor: Colors.blue,
      text: 'Formação: ${position.formacaoDesejada!}',
    );
  }

  // Habilidades requeridas
  Widget _buildRequiredSkills() {
    if (position.habilidadesRequeridas.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSkillsSection(
      title: 'Habilidades:',
      items: position.habilidadesRequeridas,
      chipColor: Colors.green[50]!,
    );
  }

  // Certificações requeridas
  Widget _buildCertifications() {
    if (!showCertifications || 
        position.certificacoesRequeridas.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildSkillsSection(
      title: 'Certificações:',
      items: position.certificacoesRequeridas,
      chipColor: Colors.orange[50]!,
    );
  }

  // Linha de ícones e botões de ação
  Widget _buildActionsRow() {
    if (!showActions) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildApplyButton(),
        _buildActionIcons(),
      ],
    );
  }

  // Botão Candidatar-se
  Widget _buildApplyButton() {
    if (onApply == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: onApply,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        child: const Text('Candidatar-se'),
      ),
    );
  }

  // Ícones de ação (ver, editar, excluir)
  Widget _buildActionIcons() {
    final List<Widget> actions = [];

    if (onViewDetails != null) {
      actions.add(_buildActionIcon(
        icon: Icons.visibility,
        onPressed: onViewDetails!,
        tooltip: 'Ver detalhes',
      ));
    }

    if (onEdit != null) {
      actions.add(_buildActionIcon(
        icon: Icons.edit,
        onPressed: onEdit!,
        tooltip: 'Editar',
      ));
    }

    if (onDelete != null) {
      actions.add(_buildActionIcon(
        icon: Icons.delete,
        onPressed: onDelete!,
        tooltip: 'Excluir',
        color: Colors.red,
      ));
    }

    return Row(children: actions);
  }

  // Widget auxiliar para linha de informação
  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para seção de habilidades/certificações
  Widget _buildSkillsSection({
    required String title,
    required List<String> items,
    required Color chipColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          _buildChipList(items, chipColor),
        ],
      ),
    );
  }

  // Lista de chips para habilidades/certificações
  Widget _buildChipList(List<String> items, Color chipColor) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: items
          .map((item) => Chip(
                label: Text(
                  item,
                  style: const TextStyle(fontSize: 12),
                ),
                backgroundColor: chipColor,
                visualDensity: VisualDensity.compact,
              ))
          .toList(),
    );
  }

  // Ícone de ação individual
  Widget _buildActionIcon({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20, color: color),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
    );
  }
}