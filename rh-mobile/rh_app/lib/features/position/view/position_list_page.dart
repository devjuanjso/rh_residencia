import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_app/features/position/model/position_model.dart';
import '../viewmodel/position_list_viewmodel.dart';
import 'position_form_page.dart';
import 'position_detail_page.dart';

class PositionListPage extends StatelessWidget {
  const PositionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PositionListViewModel()..loadPositions(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Vagas')),
        body: Consumer<PositionListViewModel>(
          builder: (context, viewModel, _) {
            // Exibe um indicador de carregamento enquanto os dados são buscados
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Exibe mensagem quando não há vagas cadastradas
            if (viewModel.positions.isEmpty) {
              return const Center(child: Text('Nenhuma vaga encontrada'));
            }

            // Renderiza a lista de vagas como itens clicáveis
            return ListView.builder(
              itemCount: viewModel.positions.length,
              itemBuilder: (context, index) {
                final Position vaga = viewModel.positions[index];
                return ListTile(
                  title: Text(vaga.titulo),
                  subtitle: Text(vaga.descricao ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botão para visualizar detalhes da vaga
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PositionDetailPage(position: vaga),
                            ),
                          );
                        },
                      ),
                      // Botão para editar uma vaga existente
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PositionFormPage(vaga: vaga),
                            ),
                          );
                        },
                      ),
                      // Botão para remover uma vaga da lista
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => viewModel.removePosition(vaga.id),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          // Navega para a tela de criação de nova vaga
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PositionFormPage(),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}