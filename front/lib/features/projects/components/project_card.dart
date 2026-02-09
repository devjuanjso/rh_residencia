import 'package:flutter/material.dart';
import '../model/project_model.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback? onTap;
  final VoidCallback? onViewPositions;
  final bool showPositionsButton;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTap,
    this.onViewPositions,
    this.showPositionsButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 6,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProjectImage(),
            _buildProjectContent(),
          ],
        ),
      ),
    );
  }

  // Imagem do projeto com fallback
  Widget _buildProjectImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(20),
      ),
      child: Image.network(
        project.imagem ?? '',
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageError(),
      ),
    );
  }

  // Conteúdo textual do cartão
  Widget _buildProjectContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProjectTitle(),
          const SizedBox(height: 8),
          _buildProjectDescription(),
          if (showPositionsButton && onViewPositions != null) ...[
            const SizedBox(height: 16),
            _buildPositionsButton(),
          ],
        ],
      ),
    );
  }

  // Título do projeto
  Widget _buildProjectTitle() {
    return Text(
      project.nome,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Descrição do projeto
  Widget _buildProjectDescription() {
    return Text(
      project.descricao,
      style: const TextStyle(fontSize: 16),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Botão para ver vagas do projeto
  Widget _buildPositionsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onViewPositions,
        child: const Text('Ver Vagas'),
      ),
    );
  }

  // Fallback para imagem indisponível
  Widget _buildImageError() {
    return Container(
      height: 220,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
      ),
    );
  }
}