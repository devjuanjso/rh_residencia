import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/loading_overlay.dart';
import '../../../core/layout/empty_state.dart';
import '../components/project_card.dart';
import '../components/position_list_item.dart';
import '../viewmodel/project_list_viewmodel.dart';

class ProjectListPage extends StatelessWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectListViewModel()..carregarProjetosPublicados(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Projetos'),
          centerTitle: true,
        ),
        body: Consumer<ProjectListViewModel>(
          builder: (context, vm, _) {
            return _buildBodyContent(vm);
          },
        ),
      ),
    );
  }

  Widget _buildBodyContent(ProjectListViewModel vm) {
    if (vm.loading && vm.projetos.isEmpty) {
      return _buildLoadingState();
    }

    if (vm.projetos.isEmpty) {
      return _buildEmptyProjectsState();
    }

    return _buildProjectPager(vm);
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildEmptyProjectsState() {
    return const EmptyState(
      icon: Icons.work_outline,
      title: 'Nenhum projeto encontrado',
      description: 'Crie seu primeiro projeto para começar',
    );
  }

  Widget _buildProjectPager(ProjectListViewModel vm) {
    final projeto = vm.projetos[vm.projetoAtual];

    return PageView(
      scrollDirection: Axis.vertical,
      children: [
        _buildProjectDetailsPage(vm, projeto),
        _buildProjectPositionsPage(vm, projeto),
      ],
    );
  }

  Widget _buildProjectDetailsPage(ProjectListViewModel vm, projeto) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: ProjectCard(
              project: projeto,
              showPositionsButton: false,
            ),
          ),
          const SizedBox(height: 12),
          _buildSwipeHint(),
        ],
      ),
    );
  }

  Widget _buildProjectPositionsPage(ProjectListViewModel vm, projeto) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPositionsTitle(projeto.nome),
          const SizedBox(height: 12),
          Expanded(child: _buildPositionsList(vm)),
          const SizedBox(height: 12),
          _buildNextProjectButton(vm),
        ],
      ),
    );
  }

  Widget _buildPositionsTitle(String nomeProjeto) {
    return Text(
      'Vagas de $nomeProjeto',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPositionsList(ProjectListViewModel vm) {
    return LoadingOverlay(
      isLoading: vm.loadingVagas,
      message: 'Carregando vagas...',
      child: vm.vagasDoProjeto.isEmpty
          ? _buildEmptyPositionsState()
          : _buildPositionsListView(vm),
    );
  }

  Widget _buildEmptyPositionsState() {
    return const EmptyState(
      icon: Icons.work_outline,
      title: 'Nenhuma vaga disponível',
      description: 'Este projeto ainda não possui vagas',
    );
  }

  Widget _buildPositionsListView(ProjectListViewModel vm) {
    return ListView.builder(
      itemCount: vm.vagasDoProjeto.length,
      itemBuilder: (context, index) {
        final vaga = vm.vagasDoProjeto[index];
        return _buildPositionListItem(context, vaga);
      },
    );
  }

  Widget _buildPositionListItem(BuildContext context, vaga) {
    final vm = context.watch<ProjectListViewModel>();
    final jaCandidatado = vm.jaSeCandidatou(vaga.id);

    return PositionListItem(
      position: vaga,
      applied: jaCandidatado,
      onApply: jaCandidatado
          ? null
          : () async {
              try {
                final sucesso = await vm.candidatarSe(vaga.id);

                if (sucesso) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Candidatura enviada com sucesso!"),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Erro: $e"),
                  ),
                );
              }
            },
      showActions: true,
      showEducation: false,
      showCertifications: false,
    );
  }

  Widget _buildNextProjectButton(ProjectListViewModel vm) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: vm.projetoAtual < vm.projetos.length - 1
            ? () => vm.irParaProximoProjeto()
            : null,
        icon: const Icon(Icons.arrow_forward),
        label: Text(
          vm.projetoAtual < vm.projetos.length - 1
              ? 'Próximo projeto'
              : 'Último projeto',
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeHint() {
    return const Text(
      'Arraste para baixo para ver as vagas',
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey,
      ),
    );
  }
}