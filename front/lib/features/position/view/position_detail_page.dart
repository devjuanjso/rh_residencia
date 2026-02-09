import 'package:flutter/material.dart';
import '../components/position_detail_section.dart';
import '../model/position_model.dart';
import '../controller/position_controller.dart';

class PositionDetailPage extends StatelessWidget {
  final Position position;

  const PositionDetailPage({super.key, required this.position});

  Future<void> _apagarVaga(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja apagar esta vaga?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'APAGAR',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await PositionController.delete(position.id);
        
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vaga apagada com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao apagar vaga'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Vaga'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _apagarVaga(context),
            tooltip: 'Excluir vaga',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Seção de detalhes
              PositionDetailSection(position: position),
              
              const SizedBox(height: 24),
              
              // Botão de ação secundário
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _apagarVaga(context),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'APAGAR VAGA',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}