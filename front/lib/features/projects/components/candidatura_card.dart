import 'package:flutter/material.dart';
import 'package:front/features/candidatura/model/candidatura_model.dart';

class CandidaturaCard extends StatelessWidget {
  final Candidatura candidatura;
  static const Color _purple = Color(0xFF6B21A8);

  const CandidaturaCard({super.key, required this.candidatura});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCover(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        candidatura.projetoNome,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    _buildStatusBadge(candidatura.status),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.work_outline, candidatura.vagaTitulo),
                const SizedBox(height: 6),
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Candidatado em ${_formatDate(candidatura.data)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCover() {
    if (candidatura.projetoImagem != null &&
        candidatura.projetoImagem!.isNotEmpty) {
      return SizedBox(
        height: 160,
        width: double.infinity,
        child: Image.network(
          candidatura.projetoImagem!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholderCover(),
        ),
      );
    }
    return _placeholderCover();
  }

  Widget _placeholderCover() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white30, size: 48),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final config = switch (status) {
      'aceito'    => (Colors.green.shade100,    Colors.green.shade800,    'Aceito'),
      'rejeitado' => (Colors.red.shade100,      Colors.red.shade800,      'Rejeitado'),
      _           => (Colors.orange.shade100,   Colors.orange.shade800,   'Pendente'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: config.$1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        config.$3,
        style: TextStyle(
          color: config.$2,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}