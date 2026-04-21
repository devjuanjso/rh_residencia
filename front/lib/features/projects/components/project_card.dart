import 'package:flutter/material.dart';
import '../model/project_model.dart';
import 'project_default_cover.dart';

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

  Widget _buildProjectImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: project.imagem != null && project.imagem!.isNotEmpty
          ? Image.network(
              project.imagem!,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  ProjectDefaultCover(tipo: project.tipo, height: 220),
            )
          : ProjectDefaultCover(tipo: project.tipo, height: 220),
    );
  }

  Widget _buildProjectContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProjectTitle(),
          const SizedBox(height: 8),
          _buildProjectDescription(),
          const SizedBox(height: 12),
          _buildInfoRows(),
          if (showPositionsButton && onViewPositions != null) ...[
            const SizedBox(height: 16),
            _buildPositionsButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildProjectTitle() {
    return Text(
      project.nome,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildProjectDescription() {
    return Text(
      project.descricao,
      style: const TextStyle(fontSize: 14, color: Colors.black54),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildInfoRows() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (project.tipo != null) ...[
          _buildInfoRow(
            Icons.info_outline,
            _formatarTipo(project.tipo!),
            bold: true,
          ),
          const SizedBox(height: 8),
        ],
        if (project.dataInicio != null) ...[
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Inicio: ${_formatarData(project.dataInicio!)}',
          ),
          const SizedBox(height: 8),
        ],
        if (project.criadoPorNome != null)
          _buildInfoRow(
            Icons.people_outline,
            'Criado por ${project.criadoPorNome}',
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {bool bold = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.black87,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPositionsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onViewPositions,
        child: const Text('Ver Vagas'),
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  String _formatarTipo(String tipo) {
    return tipo
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}