import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/skill_input_section.dart';
import '../model/position_model.dart';
import '../viewmodel/position_form_viewmodel.dart';

class PositionFormPage extends StatefulWidget {
  final Position? vaga;
  final String projetoId;
  final String? projetoNome;

  const PositionFormPage({
    super.key,
    this.vaga,
    required this.projetoId,
    this.projetoNome,
  });

  @override
  State<PositionFormPage> createState() => _PositionFormPageState();
}

class _PositionFormPageState extends State<PositionFormPage> {
  late PositionFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = PositionFormViewModel()
      ..setProjetoFixo(widget.projetoId)
      ..carregarProjetoParaDisplay(widget.projetoId, widget.projetoNome)
      ..carregarParaEdicao(widget.vaga);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<PositionFormViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(vm.isEdit ? 'Editar Vaga' : 'Criar Vaga'),
              centerTitle: true,
            ),
            body: _buildForm(context, vm),
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
          // Campo de projeto (travado/display only)
          _buildRequiredField(
            'Projeto',
            _buildProjetoField(vm),
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

  Widget _buildProjetoField(PositionFormViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              vm.projetoNome ?? 'Carregando...',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.lock, color: Colors.grey, size: 18),
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