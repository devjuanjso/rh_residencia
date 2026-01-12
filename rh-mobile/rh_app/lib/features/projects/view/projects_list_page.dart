import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_app/features/projects/viewmodel/projects_list_viewmodel.dart';

class ProjectListView extends StatelessWidget {
  const ProjectListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Cria o ViewModel e já carrega os projetos
      create: (_) => ProjectListViewModel()..carregarProjetos(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Projetos'),
          centerTitle: true,
        ),
        body: Consumer<ProjectListViewModel>(
          builder: (context, vm, _) {
            // Exibe loading inicial enquanto não há projetos
            if (vm.loading && vm.projetos.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // Mensagem quando não há projetos
            if (vm.projetos.isEmpty) {
              return const Center(child: Text('Nenhum projeto encontrado.'));
            }

            // Projeto atualmente selecionado
            final projeto = vm.projetos[vm.projetoAtual];

            // PageView vertical: página 1 projeto / página 2 vagas
            return PageView(
              scrollDirection: Axis.vertical,
              children: [
                // Página de informações do projeto
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
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                child: Image.network(
                                  projeto.imagem ?? '',
                                  height: 220,
                                  fit: BoxFit.cover,
                                  // fallback quando a imagem falha
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80),
                                ),
                              ),
                              // Texto do projeto
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      projeto.nome,
                                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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

                // Página das vagas do projeto
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Título das vagas
                      Text(
                        'Vagas de ${projeto.nome}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Lista de vagas ou loading
                      Expanded(
                        child: vm.loadingVagas
                            ? const Center(child: CircularProgressIndicator())
                            : vm.vagasDoProjeto.isEmpty
                                ? const Center(child: Text('Nenhuma vaga para este projeto.'))
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

                      // Botão para trocar para o próximo projeto (ainda nao funcional)
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
        ),
      ),
    );
  }
}
