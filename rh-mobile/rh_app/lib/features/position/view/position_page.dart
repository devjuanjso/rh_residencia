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

    // Carrega os projetos ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectViewModel>().carregarProjetos();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Observa o ViewModel
    final vm = context.watch<ProjectViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Vaga'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: vm.loadingProjetos
            // Indicador de carregamento de projetos
            ? const Center(child: CircularProgressIndicator())
            // Conteúdo do formulário
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seleção de projeto
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

                    // Campo título da vaga
                    const Text('Título da vaga'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: vm.tituloController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Campo descrição da vaga
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

                    // Seção de habilidades
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
                        // Botão para adicionar habilidade
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: vm.adicionarHabilidade,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Chips com habilidades adicionadas
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

                    // Seção de certificações
                    const Text('Certificações'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: vm.certificacoesController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        // Botão para adicionar certificação
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: vm.adicionarCertificacao,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Chips de certificações
                    Wrap(
                      spacing: 8,
                      children: vm.certificacoesRequeridas
                          .map(
                            (h) => Chip(
                              label: Text(h),
                              onDeleted: () => vm.removerCertificacao(h),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 24),

                    // Seção de formação
                    const Text('Formação'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: vm.formacaoController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        // Botão para adicionar formação
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: vm.adicionarFormacao,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Chips de formação
                    Wrap(
                      spacing: 8,
                      children: vm.formacaoRequeridas
                          .map(
                            (h) => Chip(
                              label: Text(h),
                              onDeleted: () => vm.removerFormacao(h),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 24),

                    // Botão para salvar vaga
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
