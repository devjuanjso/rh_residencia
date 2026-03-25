import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/image_picker_field.dart';
import '../../../core/components/loading_overlay.dart';
import 'project_detail_page.dart';
import '../viewmodel/project_form_viewmodel.dart';
import '../controller/project_controller.dart';

const _purple = Color(0xFF7F77DD);
const _purpleDark = Color(0xFF534AB7);
const _purpleLight = Color(0xFFEEEDFE);
const _purpleMid = Color(0xFFAFA9EC);

class ProjectFormPage extends StatefulWidget {
  final String? projetoId;
  const ProjectFormPage({super.key, this.projetoId});

  @override
  State<ProjectFormPage> createState() => _ProjectsFormPageState();
}

class _ProjectsFormPageState extends State<ProjectFormPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProjectFormViewModel>();
      vm.carregarChoices();
      if (widget.projetoId != null) {
        vm.buscarProjetoParaEdicao(widget.projetoId!);
      } else {
        vm.limparDados();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Consumer<ProjectFormViewModel>(
        builder: (context, vm, _) {
          return LoadingOverlay(
            isLoading: widget.projetoId != null && vm.loading && !vm.dadosCarregados,
            message: 'Carregando projeto...',
            child: _buildContent(context, vm),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      titleSpacing: 20,
      title: Consumer<ProjectFormViewModel>(
        builder: (context, vm, _) => Text(
          vm.screenTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
      leading: null,
      automaticallyImplyLeading: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.black54),
            style: IconButton.styleFrom(
              shape: const CircleBorder(),
              side: const BorderSide(color: Color(0xFFDDDDDD), width: 0.5),
              padding: const EdgeInsets.all(6),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0.5),
        child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFE0E0E0)),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProjectFormViewModel vm) {
    if (widget.projetoId != null && !vm.loading && vm.projetoId == null) {
      return _buildNotFoundError();
    }
    return _buildFormContent(context, vm);
  }

  Widget _buildNotFoundError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 52, color: Color(0xFFE24B4A)),
          const SizedBox(height: 16),
          const Text('Projeto não encontrado',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _purple),
              foregroundColor: _purple,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, ProjectFormViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(
            label: 'Nome do projeto',
            required: true,
            child: _styledTextField(
              controller: vm.nomeController,
              hint: 'Nome do projeto',
            ),
          ),
          const SizedBox(height: 18),
          _buildField(
            label: 'Descrição',
            child: _styledTextField(
              controller: vm.descricaoController,
              hint: 'Sobre o projeto',
              maxLines: 4,
            ),
          ),
          const SizedBox(height: 18),
          _buildTipoField(vm),
          const SizedBox(height: 18),
          _buildDataInicioField(context, vm),
          const SizedBox(height: 18),
          _buildImagePicker(vm),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(height: 0.5, thickness: 0.5, color: Color(0xFFE8E8E8)),
          ),
          _buildActionButton(vm, context),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required Widget child,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF666666),
              letterSpacing: 0.2,
            ),
            children: required
                ? const [TextSpan(text: ' *', style: TextStyle(color: _purple))]
                : null,
          ),
        ),
        const SizedBox(height: 5),
        child,
      ],
    );
  }

  Widget _styledTextField({
    TextEditingController? controller,
    String hint = '',
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _purple, width: 1),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildTipoField(ProjectFormViewModel vm) {
    final opcoes = vm.tiposDisponiveis
        .map((e) => DropdownMenuItem(value: e["value"], child: Text(e["label"]!)))
        .toList();

    return _buildField(
      label: 'Área',
      required: true,
      child: DropdownButtonFormField<String>(
        value: vm.tipo,
        hint: const Text('Selecione a área',
            style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 14)),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _purple, width: 1),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: Color(0xFFAAAAAA), size: 20),
        items: opcoes,
        onChanged: vm.setTipo,
      ),
    );
  }

  Widget _buildDataInicioField(BuildContext context, ProjectFormViewModel vm) {
    final formatted = vm.dataInicio != null
        ? '${vm.dataInicio!.day.toString().padLeft(2, '0')}/'
            '${vm.dataInicio!.month.toString().padLeft(2, '0')}/'
            '${vm.dataInicio!.year}'
        : null;

    return _buildField(
      label: 'Data de início',
      required: true,
      child: GestureDetector(
        onTap: () => _selecionarData(context, vm),
        child: AbsorbPointer(
          child: TextField(
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              hintText: formatted ?? 'DD/MM/AAAA',
              hintStyle: TextStyle(
                color: formatted != null ? Colors.black87 : const Color(0xFFBBBBBB),
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _purple, width: 1),
              ),
              filled: true,
              fillColor: Colors.white,
              suffixIcon: const Icon(Icons.calendar_today_outlined,
                  size: 16, color: Color(0xFFAAAAAA)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selecionarData(BuildContext context, ProjectFormViewModel vm) async {
    final hoje = DateTime.now();
    final selecionada = await showDatePicker(
      context: context,
      initialDate: vm.dataInicio ?? hoje,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _purple),
        ),
        child: child!,
      ),
    );
    if (selecionada != null) vm.setDataInicio(selecionada);
  }

  Widget _buildImagePicker(ProjectFormViewModel vm) {
    return _buildField(
      label: 'Imagem do projeto',
      child: ImagePickerField(
        label: '',
        initialImage: vm.imagem,
        imageUrl: vm.imagemUrlAtual,
        showKeepCurrentOption: widget.projetoId != null,
        keepCurrentImage: vm.manterImagemAtual,
        onImageSelected: vm.setImagem,
        onKeepCurrentChanged: vm.setManterImagemAtual,
      ),
    );
  }

  // Apenas o botão de ação principal (Criar / Atualizar)
  Widget _buildActionButton(ProjectFormViewModel vm, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: vm.isValid && !vm.loading
            ? () => _handleSaveAction(vm, context)
            : null,
        icon: vm.loading
            ? const SizedBox(
                width: 15,
                height: 15,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.check, size: 15, color: Colors.white),
        label: Text(
          vm.actionButtonText,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _purple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _purpleMid,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Future<void> _handleSaveAction(
      ProjectFormViewModel vm, BuildContext context) async {
    final projetoIdCriado = await vm.salvarProjeto(context);
    if (projetoIdCriado != null && context.mounted) {
      if (vm.projetoId != null) {
        Navigator.pop(context, true);
      } else {
        final projetoCriado =
            await ProjectController.buscarProjetoPorId(projetoIdCriado);
        if (projetoCriado != null && context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailPage(project: projetoCriado),
            ),
          );
        } else if (context.mounted) {
          Navigator.pop(context, true);
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}