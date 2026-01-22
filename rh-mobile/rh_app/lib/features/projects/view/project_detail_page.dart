import 'package:flutter/material.dart';
import 'package:rh_app/core/components/loading_overlay.dart';
import 'package:rh_app/core/layout/empty_state.dart';
import 'package:rh_app/features/projects/components/project_card.dart';
import 'package:rh_app/features/projects/components/position_list_item.dart';
import 'package:rh_app/features/position/model/position_model.dart';
import 'package:rh_app/features/position/view/position_form_page.dart';
import 'package:rh_app/features/position/view/position_detail_page.dart';
import 'package:rh_app/features/projects/model/project_model.dart';
import 'package:rh_app/features/projects/controller/project_controller.dart';

class ProjectDetailPage extends StatefulWidget {
  final Project project;
  
  const ProjectDetailPage({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final List<Position> _positions = [];
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _loadPositions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final positions = await ProjectController.buscarVagasPorProjeto(widget.project.id);
      setState(() {
        _positions.clear();
        _positions.addAll(positions);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar vagas: $e';
        _positions.clear();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePosition(String positionId) async {
    // TODO: Implementar lógica de exclusão
    await _loadPositions();
  }

  void _showDeleteDialog(Position position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Excluir a vaga "${position.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePosition(position.id);
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProjectCard(),
            _buildPositionsSection(),
          ],
        ),
      ),
    );
  }

  // Barra superior com botão para adicionar vagas
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.project.nome),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: _handleAddPosition,
          tooltip: 'Adicionar vaga',
        ),
      ],
    );
  }

  // Card principal do projeto
  Widget _buildProjectCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ProjectCard(
        project: widget.project,
        showPositionsButton: false,
      ),
    );
  }

  // Seção de vagas do projeto
  Widget _buildPositionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPositionsTitle(),
          const SizedBox(height: 16),
          _buildPositionsContent(),
        ],
      ),
    );
  }

  // Título da seção de vagas
  Widget _buildPositionsTitle() {
    return const Text(
      'Vagas disponíveis',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Conteúdo da lista de vagas com estados
  Widget _buildPositionsContent() {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Carregando vagas...',
      child: _buildPositionsList(),
    );
  }

  // Lista de vagas ou estado alternativo
  Widget _buildPositionsList() {
    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (_positions.isEmpty) {
      return _buildEmptyPositionsState();
    }

    return _buildPositionsListView();
  }

  // Estado de erro no carregamento
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadPositions,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  // Estado quando não há vagas
  Widget _buildEmptyPositionsState() {
    return EmptyState(
      icon: Icons.work_outline,
      title: 'Nenhuma vaga disponível',
      description: 'Adicione a primeira vaga para este projeto',
      action: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Criar vaga'),
        onPressed: _handleAddPosition,
      ),
    );
  }

  // Lista scrollável de vagas
  Widget _buildPositionsListView() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _positions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final position = _positions[index];
        return _buildPositionListItem(position);
      },
    );
  }

  // Item individual de vaga
  Widget _buildPositionListItem(Position position) {
    return PositionListItem(
      position: position,
      onViewDetails: () => _handleViewDetails(position),
      onEdit: () => _handleEditPosition(position),
      onDelete: () => _showDeleteDialog(position),
      showEducation: true,
      showCertifications: true,
    );
  }

  // Navega para página de criação de vaga
  Future<void> _handleAddPosition() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PositionFormPage(
          projetoId: widget.project.id,
        ),
      ),
    );
    
    if (result == true && mounted) {
      await _loadPositions();
    }
  }

  // Navega para detalhes da vaga
  void _handleViewDetails(Position position) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PositionDetailPage(position: position),
      ),
    );
  }

  // Navega para edição de vaga
  Future<void> _handleEditPosition(Position position) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PositionFormPage(
          vaga: position,
          projetoId: widget.project.id,
        ),
      ),
    );
    
    if (result == true && mounted) {
      await _loadPositions();
    }
  }
}