import 'package:flutter/material.dart';
import 'package:rh_app/features/position/model/position_model.dart';
import 'package:rh_app/features/position/view/position_form_page.dart';
import 'package:rh_app/features/position/view/position_detail_page.dart';
import 'package:rh_app/features/projects/model/project_model.dart';
import 'package:rh_app/features/projects/controller/project_controller.dart';

class ProjectDetailView extends StatefulWidget {
  final Project project;
  
  const ProjectDetailView({
    super.key,
    required this.project,
  });

  @override
  State<ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<ProjectDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project.nome),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PositionFormPage(
                    projetoId: widget.project.id,
                  ),
                ),
              ).then((value) {
                if (value == true) {
                  setState(() {});
                }
              });
            },
            tooltip: 'Adicionar vaga',
          ),
        ],
      ),
      body: _ProjectDetailBody(project: widget.project),
    );
  }
}

class _ProjectDetailBody extends StatefulWidget {
  final Project project;
  
  const _ProjectDetailBody({required this.project});

  @override
  State<_ProjectDetailBody> createState() => __ProjectDetailBodyState();
}

class __ProjectDetailBodyState extends State<_ProjectDetailBody> {
  List<Position> _positions = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPositions();
  }

  Future<void> _loadPositions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final positions = await ProjectController.buscarVagasPorProjeto(widget.project.id);
      setState(() {
        _positions = positions;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar vagas: $e';
        _positions = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProjectInfo(),
          _buildPositionsList(),
        ],
      ),
    );
  }

  Widget _buildProjectInfo() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.project.imagem != null && widget.project.imagem!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                widget.project.imagem!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project.nome,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.project.descricao,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vagas disponíveis',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage.isNotEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else if (_positions.isEmpty)
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.work_outline,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma vaga disponível',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione a primeira vaga para este projeto',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Criar vaga'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PositionFormPage(
                            projetoId: widget.project.id,
                          ),
                        ),
                      ).then((value) {
                        if (value == true) {
                          _loadPositions();
                        }
                      });
                    },
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _positions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final position = _positions[index];
                return _buildPositionCard(position);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPositionCard(Position position) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              position.titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            if (position.descricao != null && position.descricao!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  position.descricao!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            
            if (position.formacaoDesejada != null && position.formacaoDesejada!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.school, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Formação: ${position.formacaoDesejada!}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            
            if (position.habilidadesRequeridas.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Habilidades:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: position.habilidadesRequeridas
                          .map((habilidade) => Chip(
                                label: Text(
                                  habilidade,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.green[50],
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            
            if (position.certificacoesRequeridas.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Certificações:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: position.certificacoesRequeridas
                          .map((certificacao) => Chip(
                                label: Text(
                                  certificacao,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                backgroundColor: Colors.orange[50],
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PositionDetailPage(position: position),
                      ),
                    );
                  },
                  tooltip: 'Ver detalhes',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
                
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PositionFormPage(
                          vaga: position, 
                          projetoId: widget.project.id,
                        ),
                      ),
                    ).then((value) {
                      if (value == true) {
                        _loadPositions();
                      }
                    });
                  },
                  tooltip: 'Editar vaga',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                ),
                
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    _showDeleteDialog(position);
                  },
                  tooltip: 'Excluir vaga',
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Position position) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Tem certeza que deseja excluir a vaga "${position.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Aqui você precisa implementar a função para excluir a vaga
              // Exemplo: await PositionController.excluirVaga(position.id);
              _loadPositions();
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
}