import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_app/features/position/viewmodel/position_viewmodel.dart';

class PositionPage extends StatefulWidget {
  const PositionPage({super.key});

  @override
  State<PositionPage> createState() => _PositionPageState();
}

class _PositionPageState extends State<PositionPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectViewModel>().carregarProjetos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProjectViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Vaga'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: vm.loadingProjetos
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Projeto'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: vm.projectId,
                      items: vm.projetos
                          .map(
                            (project) => DropdownMenuItem<String>(
                              value: project.id,
                              child: Text(project.nome),
                            ),
                          )
                          .toList(),
                      onChanged: vm.selecionarProjeto,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('Título da vaga'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: vm.tituloController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('Descrição'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: vm.descricaoController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text('Habilidades'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: vm.habilidadeController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: vm.adicionarHabilidade,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      children: vm.habilidadesRequeridas
                          .map(
                            (h) => Chip(
                              label: Text(h),
                              onDeleted: () => vm.removerHabilidade(h),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 24),

                    const Text('Habilidades'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: vm.habilidadeController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: vm.adicionarHabilidade,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      children: vm.habilidadesRequeridas
                          .map(
                            (h) => Chip(
                              label: Text(h),
                              onDeleted: () => vm.removerHabilidade(h),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            vm.loading ? null : () => vm.salvarVaga(context),
                        child: vm.loading
                            ? const CircularProgressIndicator()
                            : const Text('Salvar Vaga'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
