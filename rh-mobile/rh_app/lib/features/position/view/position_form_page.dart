import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rh_app/core/components/loading_overlay.dart';
import 'package:rh_app/features/position/components/skill_input_section.dart';
import 'package:rh_app/features/position/model/position_model.dart';
import 'package:rh_app/features/position/viewmodel/position_form_viewmodel.dart';
import 'package:rh_app/features/projects/model/project_model.dart';

class PositionFormPage extends StatelessWidget {
  final Position? vaga;
  final String projetoId;

  const PositionFormPage({
    super.key,
    this.vaga,
    required this.projetoId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PositionFormViewModel()
        ..carregarProjetos()
        ..carregarParaEdicao(vaga),
      child: Consumer<PositionFormViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(vm.isEdit ? 'Editar Vaga' : 'Criar Vaga'),
              centerTitle: true,
            ),
            body: LoadingOverlay(
              isLoading: vm.loadingProjetos,
              message: 'Carregando projetos...',
              child: _buildForm(context, vm),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, PositionFormViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo de seleção de projeto
          _buildRequiredField(
            'Projeto',
            DropdownButtonFormField<String>(
              value: vm.projectId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Selecione um projeto',
              ),
              items: vm.projetos.map((Project p) {
                return DropdownMenuItem(
                  value: p.id,
                  child: Text(p.nome),
                );
              }).toList(),
              onChanged: vm.selecionarProjeto,
            ),
          ),
          const SizedBox(height: 16),

          // Campo de título
          _buildRequiredField(
            'Título',
            TextField(
              controller: vm.tituloController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Digite o título da vaga',
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Campo de descrição
          _buildRequiredField(
            'Descrição',
            TextField(
              controller: vm.descricaoController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Descreva as responsabilidades da vaga',
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Habilidades
          SkillInputSection(
            title: 'Habilidades Requeridas',
            controller: vm.habilidadeController,
            items: vm.habilidadesRequeridas,
            onAdd: vm.adicionarHabilidade,
            onRemove: vm.removerHabilidade,
            hintText: 'Ex: Flutter, Dart, Firebase',
          ),
          const SizedBox(height: 24),

          // Certificações
          SkillInputSection(
            title: 'Certificações Requeridas',
            controller: vm.certificacoesController,
            items: vm.certificacoesRequeridas,
            onAdd: vm.adicionarCertificacao,
            onRemove: vm.removerCertificacao,
            hintText: 'Ex: AWS Certified, Scrum Master',
          ),
          const SizedBox(height: 24),

          // Formação desejada
          _buildOptionalField(
            'Formação Desejada (Opcional)',
            TextField(
              controller: vm.formacaoController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ex: Ciência da Computação, Engenharia de Software',
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Botão de salvar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: vm.loading ? null : () => vm.salvarVaga(context),
              child: vm.loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      vm.isEdit ? 'ATUALIZAR VAGA' : 'SALVAR VAGA',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }

  Widget _buildOptionalField(String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}