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
          // Cabeçalho com título e ações
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
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
              if (showActions && (onEdit != null || onDelete != null || onView != null))
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
          ),
          
          // Descrição
          if (position.descricao != null && position.descricao!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                position.descricao!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          // Habilidades (mostra apenas as 3 primeiras)
          if (position.habilidadesRequeridas.isNotEmpty)
            Padding(
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
            ),
        ],
      ),
    );
  }
}