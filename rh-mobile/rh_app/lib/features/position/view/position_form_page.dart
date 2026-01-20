import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_app/features/position/model/position_model.dart';
import 'package:rh_app/features/position/viewmodel/position_form_viewmodel.dart';
import 'package:rh_app/features/projects/model/project_model.dart';

class PositionFormPage extends StatelessWidget {
  final Position? vaga;

  const PositionFormPage({super.key, this.vaga, required String projetoId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Inicializa o ViewModel e carrega dados necessários
      create: (_) => PositionViewModel()
        ..carregarProjetos()
        ..carregarParaEdicao(vaga),
      child: Consumer<PositionViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              // Altera o título baseado no modo (criar/editar)
              title: Text(vm.isEdit ? 'Editar Vaga' : 'Criar Vaga'),
              centerTitle: true,
            ),
            body: vm.loadingProjetos
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Campo de seleção para associar vaga a um projeto
                        DropdownButtonFormField<String>(
                          value: vm.projectId,
                          decoration: const InputDecoration(
                            labelText: 'Projeto',
                            border: OutlineInputBorder(),
                          ),
                          items: vm.projetos.map((Project p) {
                            return DropdownMenuItem(
                              value: p.id,
                              child: Text(p.nome),
                            );
                          }).toList(),
                          onChanged: vm.selecionarProjeto,
                        ),
                        const SizedBox(height: 16),
                        // Campo de entrada para o título da vaga
                        TextField(
                          controller: vm.tituloController,
                          decoration: const InputDecoration(
                            labelText: 'Título',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Campo de entrada para a descrição da vaga
                        TextField(
                          controller: vm.descricaoController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Descrição',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Componente para adicionar/remover habilidades
                        _listInput(
                          title: 'Habilidades',
                          controller: vm.habilidadeController,
                          items: vm.habilidadesRequeridas,
                          onAdd: vm.adicionarHabilidade,
                          onRemove: vm.removerHabilidade,
                        ),
                        const SizedBox(height: 24),
                        // Componente para adicionar/remover certificações
                        _listInput(
                          title: 'Certificações',
                          controller: vm.certificacoesController,
                          items: vm.certificacoesRequeridas,
                          onAdd: vm.adicionarCertificacao,
                          onRemove: vm.removerCertificacao,
                        ),
                        const SizedBox(height: 24),
                        // Campo de entrada para formação desejada (opcional)
                        TextField(
                          controller: vm.formacaoController,
                          decoration: const InputDecoration(
                            labelText: 'Formação desejada',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Botão principal para salvar ou atualizar a vaga
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: vm.loading
                                ? null
                                : () => vm.salvarVaga(context),
                            child: vm.loading
                                ? const CircularProgressIndicator()
                                : Text(
                                    vm.isEdit
                                        ? 'Atualizar vaga'
                                        : 'Salvar vaga',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  // Componente reutilizável para listas de itens (habilidades/certificações)
  Widget _listInput({
    required String title,
    required TextEditingController controller,
    required List<String> items,
    required VoidCallback onAdd,
    required Function(String) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              // Campo de texto para adicionar novo item à lista
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onAdd(),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            // Botão para adicionar item à lista
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAdd,
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Exibe os itens já adicionados como chips clicáveis
        Wrap(
          spacing: 8,
          children: items
              .map(
                (e) => Chip(
                  label: Text(e),
                  onDeleted: () => onRemove(e),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}