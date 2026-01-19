import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_app/features/projects/model/project_model.dart';
import 'package:rh_app/features/projects/view/project_form_page.dart';
import 'package:rh_app/features/projects/viewmodel/project_list_viewmodel.dart';

class ProjectListPage extends StatefulWidget {
  const ProjectListPage({super.key});

  @override
  State<ProjectListPage> createState() => _ProjectListPageState();
}

class _ProjectListPageState extends State<ProjectListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProjectListViewModel()..carregarProjetos(),
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Projetos'),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(icon: Icon(Icons.swipe), text: 'Descobrir'),
                Tab(icon: Icon(Icons.list), text: 'Gerenciar'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: const [
              _DiscoverTab(),
              _ManageTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// Aba para descoberta de projetos estilo Tinder
class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectListViewModel>(
      builder: (context, vm, _) {
        // Exibe loading enquanto carrega dados
        if (vm.loading && vm.projetos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Mensagem para lista vazia
        if (vm.projetos.isEmpty) {
          return const Center(child: Text('Nenhum projeto encontrado.'));
        }

        // Projeto atual sendo exibido
        final projeto = vm.projetos[vm.projetoAtual];

        return PageView(
          scrollDirection: Axis.vertical,
          children: [
            // Página 1: Card do projeto
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Imagem do projeto
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            child: Image.network(
                              projeto.imagem ?? '',
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.broken_image, size: 80),
                            ),
                          ),
                          // Informações do projeto
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  projeto.nome,
                                  style: const TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  projeto.descricao,
                                  style: const TextStyle(fontSize: 16),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Instrução para o usuário
                  const Text('Arraste para baixo para ver as vagas'),
                ],
              ),
            ),
            // Página 2: Vagas do projeto
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Título da seção de vagas
                  Text(
                    'Vagas de ${projeto.nome}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  // Lista de vagas
                  Expanded(
                    child: vm.loadingVagas
                        ? const Center(child: CircularProgressIndicator())
                        : vm.vagasDoProjeto.isEmpty
                            ? const Center(
                                child: Text('Nenhuma vaga para este projeto.'))
                            : ListView.builder(
                                itemCount: vm.vagasDoProjeto.length,
                                itemBuilder: (context, index) {
                                  final vaga = vm.vagasDoProjeto[index];
                                  return Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ListTile(
                                      title: Text(vaga.titulo),
                                      subtitle: Text(vaga.descricao ?? ''),
                                      trailing: TextButton(
                                        onPressed: () {},
                                        child: const Text('Candidatar-se'),
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                  const SizedBox(height: 12),
                  // Botão para passar para próximo projeto
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await vm.irParaProximoProjeto();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Passar projeto',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// Aba para gerenciamento de projetos
class _ManageTab extends StatelessWidget {
  const _ManageTab();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProjectListViewModel>();

    // Carrega projetos na primeira renderização
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (vm.projetosAdmin.isEmpty && !vm.loadingAdmin) {
        vm.carregarProjetosAdmin();
      }
    });

    // Exibe loading enquanto carrega dados
    if (vm.loadingAdmin && vm.projetosAdmin.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Mensagem para lista vazia
    if (vm.projetosAdmin.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum projeto cadastrado'),
          ],
        ),
      );
    }

    // Lista de projetos com refresh
    return RefreshIndicator(
      onRefresh: () => vm.carregarProjetosAdmin(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vm.projetosAdmin.length,
        itemBuilder: (context, index) {
          final projeto = vm.projetosAdmin[index];
          return _ProjectListItem(projeto: projeto, viewModel: vm);
        },
      ),
    );
  }
}

// Item individual da lista de projetos
class _ProjectListItem extends StatelessWidget {
  final Project projeto;
  final ProjectListViewModel viewModel;

  const _ProjectListItem({
    required this.projeto,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        // Avatar com imagem do projeto
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[200],
          backgroundImage:
              projeto.imagem != null ? NetworkImage(projeto.imagem!) : null,
          child: projeto.imagem == null
              ? const Icon(Icons.business, color: Colors.grey)
              : null,
        ),
        // Nome do projeto
        title: Text(
          projeto.nome,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        // Descrição resumida
        subtitle: Text(
          projeto.descricao.length > 50
              ? '${projeto.descricao.substring(0, 50)}...'
              : projeto.descricao,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // Botões de ação
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botão de editar
            IconButton(
              onPressed: () {
                _navegarParaEditarProjeto(context, projeto);
              },
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Editar projeto',
            ),
            // Botão de deletar
            IconButton(
              onPressed: () {
                _mostrarDialogoExcluir(context, projeto);
              },
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: 'Excluir projeto',
            ),
          ],
        ),
        // Abre detalhes ao clicar no item
        onTap: () {
          _mostrarDetalhesProjeto(context, projeto);
        },
      ),
    );
  }

  // Navega para tela de edição do projeto
  void _navegarParaEditarProjeto(BuildContext context, Project projeto) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectsFormPage(projetoId: projeto.id),
      ),
    ).then((_) {
      // Recarrega lista após edição
      context.read<ProjectListViewModel>().carregarProjetosAdmin();
    });
  }

  // Exibe diálogo de confirmação para exclusão
  void _mostrarDialogoExcluir(BuildContext context, Project projeto) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Projeto'),
        content: Text('Deseja realmente excluir o projeto "${projeto.nome}"?'),
        actions: [
          // Botão cancelar
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          // Botão confirmar exclusão
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await viewModel.excluirProjeto(projeto.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Projeto "${projeto.nome}" excluído'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  // Exibe detalhes do projeto em modal
  void _mostrarDetalhesProjeto(BuildContext context, Project projeto) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagem do projeto
            if (projeto.imagem != null)
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(projeto.imagem!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            // Nome do projeto
            Text(
              projeto.nome,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Descrição completa
            Text(
              projeto.descricao,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // Primeira linha de botões
            Row(
              children: [
                // Botão fechar
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Fechar'),
                  ),
                ),
                const SizedBox(width: 8),
                // Botão ver vagas
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Implementar navegação para vagas
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Vagas de ${projeto.nome}'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.work, size: 20),
                    label: const Text('Ver Vagas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Segunda linha de botões
            Row(
              children: [
                // Botão editar
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navegarParaEditarProjeto(context, projeto);
                    },
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 8),
                // Botão excluir
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _mostrarDialogoExcluir(context, projeto);
                    },
                    icon: const Icon(Icons.delete, size: 20),
                    label: const Text('Excluir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}