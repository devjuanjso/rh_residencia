import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rh_app/features/projects/viewmodel/project_form_viewmodel.dart';

class ProjectsFormPage extends StatefulWidget {
  final String? projetoId;

  const ProjectsFormPage({super.key, this.projetoId});

  @override
  State<ProjectsFormPage> createState() => _ProjectsFormPageState();
}

class _ProjectsFormPageState extends State<ProjectsFormPage> {
  bool _isPickingImage = false;

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
          if (widget.projetoId != null && vm.loading && !vm.dadosCarregados) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.projetoId != null && !vm.loading && vm.projetoId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Projeto não encontrado'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            );
          }

          return _buildFormContent(context, vm);
        },
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, ProjectFormViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
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
                hintText: 'Adicione o nome do Projeto',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Descrição do projeto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: vm.descricaoController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Adicione uma descrição ao projeto',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            _buildImageSection(context, vm),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isValid && !vm.loading
                    ? () async {
                        final sucesso = await vm.salvarProjeto(context);
                        if (sucesso && context.mounted) {
                          Navigator.pop(context);
                        }
                      }
                    : null,
                child: vm.loading
                    ? const CircularProgressIndicator()
                    : Text(vm.actionButtonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, ProjectFormViewModel vm) {
    final bool estaEditando = widget.projetoId != null;
    final bool temImagemUrl = vm.imagemUrlAtual != null && vm.imagemUrlAtual!.isNotEmpty;
    final bool temImagemNova = vm.imagem != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagem do projeto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        if (estaEditando && temImagemUrl)
          Column(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    vm.imagemUrlAtual!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 40),
                            SizedBox(height: 8),
                            Text('Imagem não carregada'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: vm.manterImagemAtual,
                            onChanged: (value) {
                              vm.setManterImagemAtual(value ?? true);
                            },
                          ),
                          const Expanded(
                            child: Text(
                              'Manter imagem atual',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      if (!vm.manterImagemAtual)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Ao desmarcar, você poderá selecionar uma nova imagem',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),

        if (!estaEditando || !vm.manterImagemAtual || !temImagemUrl)
          Column(
            children: [
              GestureDetector(
                onTap: _isPickingImage ? null : () => _pickImage(context, vm),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildImagePreview(vm, temImagemNova),
                ),
              ),
              
              if (temImagemNova && !vm.loading)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: () => vm.setImagem(null),
                    icon: const Icon(Icons.delete, size: 20),
                    label: const Text('Remover imagem selecionada'),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildImagePreview(ProjectFormViewModel vm, bool temImagemNova) {
    if (temImagemNova) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          vm.imagem!,
          fit: BoxFit.cover,
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image, size: 40, color: _isPickingImage ? Colors.grey : null),
          const SizedBox(height: 8),
          Text(
            _isPickingImage ? 'Aguarde...' : 'Toque para adicionar foto',
            style: TextStyle(color: _isPickingImage ? Colors.grey : null),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ProjectFormViewModel vm) async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedImage != null && context.mounted) {
        vm.setImagem(File(pickedImage.path));
        
        if (widget.projetoId != null && vm.manterImagemAtual) {
          vm.setManterImagemAtual(false);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }
}