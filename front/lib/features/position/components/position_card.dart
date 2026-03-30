import 'package:flutter/material.dart';
import '../model/position_model.dart';
import '../../../core/components/custom_card.dart';

class PositionCard extends StatelessWidget {
  final Position position;
  final VoidCallback? onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const PositionCard({
    super.key,
    required this.position,
    this.onView,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSkills(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  position.titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (position.senioridade != null) ...[
                const SizedBox(width: 8),
                _buildSenioridadeBadge(position.senioridade!),
              ],
            ],
          ),
        ),
        if (showActions &&
            (onEdit != null || onDelete != null || onView != null))
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onView != null)
                IconButton(
                  icon: const Icon(Icons.visibility, size: 20),
                  onPressed: onView,
                  tooltip: 'Visualizar',
                ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Editar',
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Excluir',
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildSenioridadeBadge(String senioridade) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        senioridade,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSkills() {
    if (position.habilidadesRequeridas.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: position.habilidadesRequeridas
            .take(3)
            .map(
              (habilidade) => Chip(
                label: Text(habilidade),
                labelStyle: const TextStyle(fontSize: 12),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            )
            .toList(),
      ),
    );
  }
}