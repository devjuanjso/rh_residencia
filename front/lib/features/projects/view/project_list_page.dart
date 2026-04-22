import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/layout/empty_state.dart';
import '../components/position_list_item.dart';
import '../model/project_model.dart';
import '../viewmodel/project_list_viewmodel.dart';
import '../../position/model/position_model.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage> {
  bool _vagasVisiveis = true;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectListViewModel()..carregarProjetosPublicados(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<ProjectListViewModel>(
            builder: (context, vm, _) {
              return _buildBody(context, vm);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProjectListViewModel vm) {
    if (vm.loading && vm.projetos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.projetos.isEmpty) {
      return const EmptyState(
        icon: Icons.work_outline,
        title: 'Nenhum projeto encontrado',
        description: 'Crie seu primeiro projeto para começar',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: _buildHeader(vm),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: vm.projetos.length,
            onPageChanged: (index) {
              vm.irParaProjeto(index);
              setState(() => _vagasVisiveis = true);
            },
            itemBuilder: (context, index) {
              final projeto = vm.projetos[index];
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: _buildProjectCard(context, vm, projeto),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ProjectListViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vagas para você',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                '${vm.projetos.length.toString().padLeft(2, '0')} projetos disponíveis',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            _buildIconButton(Icons.tune, () {}),
            const SizedBox(width: 8),
            _buildIconButton(Icons.refresh, () {
              vm.carregarProjetosPublicados();
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.white,
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  Widget _buildProjectCard(
      BuildContext context, ProjectListViewModel vm, Project projeto) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProjectImage(projeto),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProjectInfo(projeto),
                const SizedBox(height: 16),
                _buildToggleVagasButton(),
                if (_vagasVisiveis) ...[
                  const SizedBox(height: 12),
                  _buildVagasList(context, vm),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectImage(Project projeto) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: projeto.imagem != null
          ? Image.network(
              projeto.imagem!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
            )
          : _buildImagePlaceholder(),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.black87,
      child: const Center(
        child: Icon(Icons.image, size: 60, color: Colors.white54),
      ),
    );
  }

  Widget _buildProjectInfo(Project projeto) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          projeto.nome,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          projeto.descricao,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        if (projeto.tipo != null) ...[
          _buildInfoRow(
            Icons.info_outline,
            _formatarTipo(projeto.tipo!),
            color: Colors.deepPurple,
            bold: true,
          ),
          const SizedBox(height: 8),
        ],
        if (projeto.dataInicio != null) ...[
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Inicio: ${_formatarData(projeto.dataInicio!)}',
            color: Colors.deepPurple,
          ),
          const SizedBox(height: 8),
        ],
        if (projeto.criadoPorNome != null)
          _buildInfoRow(
            Icons.people_outline,
            'Criado por ${projeto.criadoPorNome}',
            color: Colors.deepPurple,
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text,
      {Color? color, bool bold = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? Colors.grey),
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

  Widget _buildToggleVagasButton() {
    return GestureDetector(
      onTap: () => setState(() => _vagasVisiveis = !_vagasVisiveis),
      child: Text(
        _vagasVisiveis ? 'Ocultar todas as vagas' : 'Mostrar todas as vagas',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.deepPurple,
          fontWeight: FontWeight.w500,
        ),
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

  Widget _buildVagasList(BuildContext context, ProjectListViewModel vm) {
    if (vm.loadingVagas) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (vm.vagasDoProjeto.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Nenhuma vaga disponível',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
      );
    }

    return Column(
      children: vm.vagasDoProjeto.map((vaga) {
        final jaCandidatado = vm.jaSeCandidatou(vaga.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          // ✅ CORRIGIDO: sem ExpansionTile aqui — o PositionListItem já tem seu próprio toggle
          child: PositionListItem(
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
                        SnackBar(content: Text("Erro: $e")),
                      );
                    }
                  },
            showActions: true,
            showEducation: false,
            showCertifications: false,
          ),
        );
      }).toList(),
    );
  }
}