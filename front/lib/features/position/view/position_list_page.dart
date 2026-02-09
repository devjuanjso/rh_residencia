import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/loading_overlay.dart';
import '../../../core/layout/empty_state.dart';
import '../../../core/layout/error_state.dart';
import '../components/position_card.dart';
import '../model/position_model.dart';
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
        appBar: AppBar(
          title: const Text('Vagas'),
        ),
        body: Consumer<PositionListViewModel>(
          builder: (context, viewModel, _) {
            return LoadingOverlay(
              isLoading: viewModel.isLoading,
              child: _buildContent(context, viewModel),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PositionFormPage(projetoId: ''),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PositionListViewModel viewModel) {
    // Exibe mensagem de erro
    if (viewModel.errorMessage.isNotEmpty) {
      return ErrorState(
        message: viewModel.errorMessage,
        onRetry: () => viewModel.loadPositions(),
      );
    }

    // Exibe estado vazio
    if (viewModel.positions.isEmpty) {
      return EmptyState(
        icon: Icons.work_outline,
        title: 'Nenhuma vaga encontrada',
        description: 'Clique no botão + para criar sua primeira vaga',
        action: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PositionFormPage(projetoId: ''),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Criar vaga'),
        ),
      );
    }

    // Renderiza a lista de vagas
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: viewModel.positions.length,
      itemBuilder: (context, index) {
        final Position vaga = viewModel.positions[index];
        return PositionCard(
          position: vaga,
          onView: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PositionDetailPage(position: vaga),
              ),
            );
          },
          onEdit: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PositionFormPage(vaga: vaga, projetoId: ''),
              ),
            );
          },
          onDelete: () => viewModel.removePosition(vaga.id),
        );
      },
    );
  }
}