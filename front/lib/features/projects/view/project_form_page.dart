import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/components/image_picker_field.dart';
import '../../../core/components/loading_overlay.dart';
import 'project_detail_page.dart';
import '../viewmodel/project_form_viewmodel.dart';
import '../controller/project_controller.dart';

class ProjectFormPage extends StatefulWidget {
  final String? projetoId;

  const ProjectFormPage({super.key, this.projetoId});

  @override
  State<ProjectFormPage> createState() => _ProjectsFormPageState();
}

class _ProjectsFormPageState extends State<ProjectFormPage> {

  // Carrega choices e projeto (se edição) após primeiro frame
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
      appBar: AppBar(
        title: Consumer<ProjectFormViewModel>(
          builder: (context, vm, child) => Text(vm.screenTitle),
        ),
      ),
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

  // Decide entre erro de não encontrado ou formulário
  Widget _buildContent(BuildContext context, ProjectFormViewModel vm) {
    if (widget.projetoId != null && !vm.loading && vm.projetoId == null) {
      return _buildNotFoundError();
    }
    return _buildFormContent(context, vm);
  }

  // Tela de erro quando projeto não é encontrado
  Widget _buildNotFoundError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text('Projeto não encontrado', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  // Layout principal do formulário
  Widget _buildFormContent(BuildContext context, ProjectFormViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNomeField(vm),
          const SizedBox(height: 16),
          _buildDescricaoField(vm),
          const SizedBox(height: 16),
          _buildTipoField(vm),
          const SizedBox(height: 16),
          _buildDataInicioField(context, vm),
          const SizedBox(height: 16),
          _buildImagePicker(vm),
          const SizedBox(height: 24),
          _buildActionButton(vm),
        ],
      ),
    );
  }


  // Campo de texto para nome do projeto
  Widget _buildNomeField(ProjectFormViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nome do Projeto',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: vm.nomeController,
          decoration: const InputDecoration(
            hintText: 'Digite o nome do projeto',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // Campo de texto para descrição do projeto
  Widget _buildDescricaoField(ProjectFormViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Descrição do projeto',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: vm.descricaoController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Descreva o projeto',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  // Dropdown de tipo populado com choices da API
  Widget _buildTipoField(ProjectFormViewModel vm) {
    final opcoes = vm.tiposDisponiveis
        .map((e) => DropdownMenuItem(value: e["value"], child: Text(e["label"]!)))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tipo do projeto',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: vm.tipo,
          hint: const Text('Selecione o tipo'),
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: opcoes,
          onChanged: vm.setTipo,
        ),
      ],
    );
  }

  // Campo de data com date picker ao tocar
  Widget _buildDataInicioField(BuildContext context, ProjectFormViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data de início',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selecionarData(context, vm),
          child: AbsorbPointer(
            child: TextField(
              decoration: InputDecoration(
                hintText: vm.dataInicio != null
                    ? '${vm.dataInicio!.day.toString().padLeft(2, '0')}/'
                        '${vm.dataInicio!.month.toString().padLeft(2, '0')}/'
                        '${vm.dataInicio!.year}'
                    : 'Selecione a data (opcional)',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today_outlined),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Abre date picker e atualiza data no viewmodel
  Future<void> _selecionarData(BuildContext context, ProjectFormViewModel vm) async {
    final hoje = DateTime.now();
    final selecionada = await showDatePicker(
      context: context,
      initialDate: vm.dataInicio ?? hoje,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selecionada != null) vm.setDataInicio(selecionada);
  }

  // Seletor de imagem com opção de manter atual na edição
  Widget _buildImagePicker(ProjectFormViewModel vm) {
    return ImagePickerField(
      label: 'Imagem do projeto (opcional)',
      initialImage: vm.imagem,
      imageUrl: vm.imagemUrlAtual,
      showKeepCurrentOption: widget.projetoId != null,
      keepCurrentImage: vm.manterImagemAtual,
      onImageSelected: vm.setImagem,
      onKeepCurrentChanged: vm.setManterImagemAtual,
    );
  }


  // Botão de ação desabilitado durante loading ou formulário inválido
  Widget _buildActionButton(ProjectFormViewModel vm) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: vm.isValid && !vm.loading
            ? () => _handleSaveAction(vm, context)
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: vm.loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(vm.actionButtonText, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  // Salva e navega para detalhe (criação) ou volta (edição)
  Future<void> _handleSaveAction(ProjectFormViewModel vm, BuildContext context) async {
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
              builder: (context) => ProjectDetailPage(project: projetoCriado),
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