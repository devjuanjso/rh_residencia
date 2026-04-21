import 'package:flutter/material.dart';

class ProjectDefaultCover extends StatelessWidget {
  final String? tipo;
  final double height;

  const ProjectDefaultCover({super.key, this.tipo, this.height = 160});

  static _TipoConfig _configParaTipo(String? tipo) {
    switch (tipo) {
      case 'produto_digital':
        return _TipoConfig(
          gradiente: const LinearGradient(
            colors: [Color(0xFF1E3A5F), Color(0xFF4A90D9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icone: Icons.devices_outlined,
          label: 'Produto Digital',
        );
      case 'servico':
        return _TipoConfig(
          gradiente: const LinearGradient(
            colors: [Color(0xFF0F4C3A), Color(0xFF2ECC71)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icone: Icons.handshake_outlined,
          label: 'Serviço',
        );
      case 'pesquisa':
        return _TipoConfig(
          gradiente: const LinearGradient(
            colors: [Color(0xFF3B1F6E), Color(0xFF9B59B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icone: Icons.biotech_outlined,
          label: 'Pesquisa',
        );
      case 'outro':
        return _TipoConfig(
          gradiente: const LinearGradient(
            colors: [Color(0xFF7D3000), Color(0xFFE67E22)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icone: Icons.category_outlined,
          label: 'Outro',
        );
      default:
        return _TipoConfig(
          gradiente: const LinearGradient(
            colors: [Color(0xFF2C2C2C), Color(0xFF555555)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icone: Icons.folder_outlined,
          label: 'Projeto',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _configParaTipo(tipo);
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(gradient: config.gradiente),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(config.icone, size: height * 0.28, color: Colors.white38),
          const SizedBox(height: 8),
          Text(
            config.label,
            style: TextStyle(
              color: Colors.white30,
              fontSize: height * 0.09,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipoConfig {
  final LinearGradient gradiente;
  final IconData icone;
  final String label;

  const _TipoConfig({
    required this.gradiente,
    required this.icone,
    required this.label,
  });
}
