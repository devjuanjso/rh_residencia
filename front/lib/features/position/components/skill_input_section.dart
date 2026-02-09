import 'package:flutter/material.dart';

class SkillInputSection extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final List<String> items;
  final VoidCallback onAdd;
  final Function(String) onRemove;
  final String? hintText;
  final IconData? addIcon;

  const SkillInputSection({
    super.key,
    required this.title,
    required this.controller,
    required this.items,
    required this.onAdd,
    required this.onRemove,
    this.hintText,
    this.addIcon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título da seção
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        // Campo de entrada + botão
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onAdd(),
                decoration: InputDecoration(
                  hintText: hintText ?? 'Digite e pressione Enter',
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botão para adicionar
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Icon(addIcon, size: 20),
            ),
          ],
        ),
        
        // Lista de chips (itens adicionados)
        if (items.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (e) => Chip(
                    label: Text(e),
                    onDeleted: () => onRemove(e),
                    deleteIcon: const Icon(Icons.close, size: 16),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}