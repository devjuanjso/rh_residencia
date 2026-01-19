import 'package:flutter/material.dart';
import 'package:rh_app/features/position/model/position_model.dart';
import 'package:rh_app/features/position/controller/position_controller.dart';

class PositionDetailPage extends StatelessWidget {
  final Position position;

  const PositionDetailPage({super.key, required this.position});

  // Exibe um diálogo de confirmação e executa a exclusão da vaga
  Future<void> _apagarVaga(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja apagar esta vaga?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );

    // Executa a exclusão se o usuário confirmou
    if (confirmar == true) {
      try {
        await PositionController.delete(position.id);
        
        // Navega de volta e exibe mensagem de sucesso
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vaga apagada com sucesso')),
          );
        }
      } catch (e) {
        // Exibe mensagem de erro caso a exclusão falhe
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao apagar vaga')),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exibe o título principal da vaga em destaque
            Text(
              position.titulo,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Seção para a descrição da vaga (condicional)
            if (position.descricao != null && position.descricao!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descrição',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    position.descricao!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            // Seção para a formação desejada (condicional)
            if (position.formacaoDesejada != null &&
                position.formacaoDesejada!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Formação Desejada',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    position.formacaoDesejada!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            // Seção para habilidades requeridas (condicional)
            if (position.habilidadesRequeridas.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Habilidades Requeridas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Exibe habilidades como chips com espaçamento
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: position.habilidadesRequeridas
                        .map(
                          (habilidade) => Chip(
                            label: Text(habilidade),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            // Seção para certificações requeridas (condicional)
            if (position.certificacoesRequeridas.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Certificações Requeridas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Exibe certificações como chips com espaçamento
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: position.certificacoesRequeridas
                        .map(
                          (certificacao) => Chip(
                            label: Text(certificacao),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            const SizedBox(height: 30),
            // Botão para exclusão da vaga (em vermelho)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () => _apagarVaga(context),
                child: const Text('Apagar Vaga'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}