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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<ProjectFormViewModel>();
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
          builder: (context, vm, child) {
            return Text(vm.screenTitle);
          },
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

  // Constrói conteúdo principal da página
  Widget _buildContent(BuildContext context, ProjectFormViewModel vm) {
    if (widget.projetoId != null && !vm.loading && vm.projetoId == null) {
      return _buildNotFoundError();
    }

    return _buildFormContent(context, vm);
  }

  // Tela de erro quando projeto não existe
  Widget _buildNotFoundError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Projeto não encontrado',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  // Formulário de criação/edição de projeto
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
          _buildImagePicker(vm),
          const SizedBox(height: 24),
          _buildActionButton(vm),
        ],
      ),
    );
  }

  // Campo para nome do projeto
  Widget _buildNomeField(ProjectFormViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nome do Projeto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
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

  // Campo para descrição do projeto
  Widget _buildDescricaoField(ProjectFormViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descrição do projeto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
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

  // Seletor de imagem do projeto
  Widget _buildImagePicker(ProjectFormViewModel vm) {
    return ImagePickerField(
      label: 'Imagem do projeto',
      initialImage: vm.imagem,
      imageUrl: vm.imagemUrlAtual,
      showKeepCurrentOption: widget.projetoId != null,
      keepCurrentImage: vm.manterImagemAtual,
      onImageSelected: vm.setImagem,
      onKeepCurrentChanged: vm.setManterImagemAtual,
    );
  }

  // Botão principal de salvar/criar
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
            : Text(
                vm.actionButtonText,
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  // Processa ação de salvar projeto
  Future<void> _handleSaveAction(
    ProjectFormViewModel vm,
    BuildContext context,
  ) async {
    final projetoIdCriado = await vm.salvarProjeto(context);
    
    if (projetoIdCriado != null && context.mounted) {
      if (vm.projetoId != null) {
        Navigator.pop(context, true);
      } else {
        final projetoCriado = await ProjectController.buscarProjetoPorId(projetoIdCriado);
        
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