import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_app/features/projects/model/project_model.dart';
import 'package:rh_app/features/projects/view/project_detail_page.dart';
import 'package:rh_app/features/projects/view/project_form_page.dart';
import 'package:rh_app/features/projects/viewmodel/project_list_viewmodel.dart';
import 'package:rh_app/features/position/viewmodel/position_list_viewmodel.dart';

class MyProjectsPage extends StatelessWidget {
  const MyProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ProjectListViewModel()..carregarProjetos(),
        ),
        ChangeNotifierProvider(create: (_) => PositionListViewModel()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meus Projetos'),
          centerTitle: true,
        ),
        body: Consumer<ProjectListViewModel>(
          builder: (context, vm, child) {
            if (vm.loading && vm.projetos.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.projetos.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Nenhum projeto encontrado',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Clique no botão + para criar seu primeiro projeto',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.projetos.length,
              itemBuilder: (context, index) {
                final projeto = vm.projetos[index];
                return _buildProjectCard(context, projeto);
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _navigateToAddProject(context);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, Project projeto) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _navigateToProjectDetail(context, projeto);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child: projeto.imagem != null && projeto.imagem!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          projeto.imagem!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            );
                          },
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.folder, size: 40, color: Colors.grey),
                      ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projeto.nome,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      projeto.descricao,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        const Icon(Icons.date_range, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          'ID: ${projeto.id.substring(0, 8)}...',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProjectDetail(BuildContext context, Project projeto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailView(project: projeto),
      ),
    );
  }

  void _navigateToAddProject(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProjectFormPage(),
      ),
    ).then((value) {
      // Recarrega a lista de projetos após adicionar um novo
      if (value == true && context.mounted) {
        Provider.of<ProjectListViewModel>(context, listen: false).carregarProjetos();
      }
    });
  }
}