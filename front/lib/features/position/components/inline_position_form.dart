import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/position_model.dart';
import '../viewmodel/position_form_viewmodel.dart';
import 'skill_input_section.dart';

class InlinePositionForm extends StatefulWidget {
  final String projetoId;
  final String? projetoNome;
  final bool keepOpen;
  final VoidCallback onSaved;

  const InlinePositionForm({
    super.key,
    required this.projetoId,
    required this.projetoNome,
    required this.keepOpen,
    required this.onSaved,
  });

  @override
  State<InlinePositionForm> createState() => InlinePositionFormState();
}

class InlinePositionFormState extends State<InlinePositionForm> {
  late PositionFormViewModel _viewModel;
  bool _expanded = false;

  static const _purple = Color(0xFF6B21A8);
  static const _purpleAccent = Color(0xFF6B4EFF);
  static const _bgGrey = Color(0xFFF4F4F6);

  @override
  void initState() {
    super.initState();
    _viewModel = PositionFormViewModel()
      ..setProjetoFixo(widget.projetoId)
      ..carregarProjetoParaDisplay(widget.projetoId, widget.projetoNome)
      ..carregarChoices();
    _expanded = widget.keepOpen;
  }

  @override
  void didUpdateWidget(covariant InlinePositionForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.keepOpen && !_expanded) {
      setState(() => _expanded = true);
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // Pre-fills the form with data from an existing vaga and expands the section.
  void startEdit(Position vaga) {
    _viewModel.carregarParaEdicao(vaga);
    if (!_expanded) setState(() => _expanded = true);
  }

  void _toggle() {
    if (widget.keepOpen) return;
    setState(() {
      _expanded = !_expanded;
      if (!_expanded) _viewModel.limparFormulario();
    });
  }

  Future<void> _save() async {
    final ok = await _viewModel.salvarVaga(context);
    if (!mounted || !ok) return;
    widget.onSaved();
    if (!widget.keepOpen) setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<PositionFormViewModel>(
        builder: (context, vm, _) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _bgGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(vm),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: _buildBody(vm),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(PositionFormViewModel vm) {
    final tappable = !widget.keepOpen;
    final title = vm.isEdit
        ? 'Editar vaga'
        : (_expanded ? 'Adicionar vaga' : 'Adicionar nova vaga');
    return InkWell(
      onTap: tappable ? _toggle : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Row(
          children: [
            Icon(
              vm.isEdit ? Icons.edit_outlined : Icons.add_circle_outline,
              size: 20,
              color: _purpleAccent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (tappable)
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _expanded ? 0.5 : 0,
                child: const Icon(Icons.keyboard_arrow_down,
                    color: Colors.black54),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PositionFormViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Título da vaga', required: true),
        const SizedBox(height: 6),
        _buildTextField(
          controller: vm.tituloController,
          hint: 'Ex: Desenvolvedor Backend',
        ),
        const SizedBox(height: 14),
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
        _buildLabel('Formação desejada'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: vm.formacaoController,
          hint: 'Ex: Ciência da Computação',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (vm.isEdit) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: vm.loading
                      ? null
                      : () {
                          vm.limparFormulario();
                          if (!widget.keepOpen) {
                            setState(() => _expanded = false);
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancelar edição'),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: vm.loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                icon: vm.loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(vm.isEdit ? Icons.check : Icons.add, size: 18),
                label: Text(
                  vm.loading
                      ? 'Salvando...'
                      : vm.isEdit
                          ? 'Atualizar vaga'
                          : 'Adicionar vaga',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

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
          borderSide: const BorderSide(color: _purpleAccent),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
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
          borderSide: const BorderSide(color: _purpleAccent),
        ),
      ),
      hint: Text(hint, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
      items: items,
      onChanged: onChanged,
    );
  }
}
