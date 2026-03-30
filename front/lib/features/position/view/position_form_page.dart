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

  static const _purple = Color(0xFF6B4EFF);
  static const _bgGrey = Color(0xFFF4F4F6);

  @override
  void initState() {
    super.initState();
    _viewModel = PositionFormViewModel()
      ..setProjetoFixo(widget.projetoId)
      ..carregarProjetoParaDisplay(widget.projetoId, widget.projetoNome)
      ..carregarParaEdicao(widget.vaga)
      ..carregarChoices();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<PositionFormViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: const BackButton(color: Colors.black),
            title: Text(
              vm.isEdit ? 'Editar Vaga' : 'Nova Vaga',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          body: _buildBody(context, vm),
        ),
      ),
    );
  }

  // Corpo principal com scroll
  Widget _buildBody(BuildContext context, PositionFormViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(vm),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: _bgGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.isEdit ? 'Editar Vaga' : 'Adicionar Vaga',
                  style: const TextStyle(
                    color: _purple,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Título da vaga
                _buildLabel('Título da vaga', required: true),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: vm.tituloController,
                  hint: 'Ex: Desenvolvedor Backend',
                ),
                const SizedBox(height: 14),

                // Nível de senioridade
                _buildLabel('Nível', required: true),
                const SizedBox(height: 6),
                vm.loadingChoices
                    ? const LinearProgressIndicator()
                    : _buildDropdown(
                        value: vm.senioridade,
                        hint: 'Selecionar',
                        items: vm.senioridadeOpcoes
                            .map((c) => DropdownMenuItem(
                                  value: c.value,
                                  child: Text(c.label),
                                ))
                            .toList(),
                        onChanged: vm.setSenioridade,
                      ),
                const SizedBox(height: 14),

                // Área de atuação
                _buildLabel('Área', required: true),
                const SizedBox(height: 6),
                vm.loadingChoices
                    ? const LinearProgressIndicator()
                    : _buildDropdown(
                        value: vm.area,
                        hint: 'Selecionar',
                        items: vm.areaOpcoes
                            .map((c) => DropdownMenuItem(
                                  value: c.value,
                                  child: Text(c.label),
                                ))
                            .toList(),
                        onChanged: vm.setArea,
                      ),
                const SizedBox(height: 14),

                // Habilidades técnicas requeridas
                _buildLabel('Habilidades requeridas', required: true),
                const SizedBox(height: 6),
                SkillInputSection(
                  title: '',
                  controller: vm.habilidadeController,
                  items: vm.habilidadesRequeridas,
                  onAdd: vm.adicionarHabilidade,
                  onRemove: vm.removerHabilidade,
                  hintText: 'Ex: Java',
                ),
                const SizedBox(height: 14),

                // Certificações opcionais
                _buildLabel('Certificações requeridas'),
                const SizedBox(height: 6),
                SkillInputSection(
                  title: '',
                  controller: vm.certificacoesController,
                  items: vm.certificacoesRequeridas,
                  onAdd: vm.adicionarCertificacao,
                  onRemove: vm.removerCertificacao,
                  hintText: 'Ex: AWS Certified',
                ),
                const SizedBox(height: 14),

                // Formação acadêmica desejada (opcional)
                _buildLabel('Formação desejada'),
                const SizedBox(height: 6),
                _buildTextField(
                  controller: vm.formacaoController,
                  hint: 'Ex: Ciência da Computação',
                ),
                const SizedBox(height: 24),

                // Botão de salvar
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: vm.loading ? null : () => vm.salvarVaga(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: vm.loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      vm.loading
                          ? 'Salvando...'
                          : vm.isEdit
                              ? 'Atualizar vaga'
                              : 'Adicionar vaga',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Banner informativo com nome do projeto
  Widget _buildInfoBanner(PositionFormViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCEEFD),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF3A7FD5), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.isEdit ? 'Editando vaga' : 'Etapa 2: Informações da Vaga',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vm.projetoNome != null
                      ? 'Projeto: ${vm.projetoNome}'
                      : 'Preencha as informações da vaga',
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Label do campo com asterisco se obrigatório
  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        if (required) const Text(' *', style: TextStyle(color: Colors.red)),
      ],
    );
  }

  // Campo de texto padrão do formulário
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _purple),
        ),
      ),
    );
  }

  // Dropdown padrão do formulário
  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _purple),
        ),
      ),
      hint: Text(hint, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      items: items,
      onChanged: onChanged,
    );
  }
}