import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rh_app/features/projects/controller/projects_controller.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  // Controllers dos campos de texto
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController projectDescriptionController = TextEditingController();

  // Arquivo de imagem selecionado
  File? _image;

  // Instância do image picker
  final ImagePicker _picker = ImagePicker();

  // Flag de carregamento para controle de botão e indicador
  bool loading = false;

  // Seleciona uma imagem da galeria do dispositivo
  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  // Envia os dados do projeto para a API e salva
  Future<void> _salvarProjeto() async {
    // Validação simples do nome do projeto
    if (projectNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do projeto')),
      );
      return;
    }

    // Ativa estado de loading
    setState(() {
      loading = true;
    });

    // Chamada ao controller para criar o projeto
    final sucesso = await ProjectController.criarProjeto(
      nome: projectNameController.text,
      descricao: projectDescriptionController.text,
      imagem: _image,
    );

    // Desativa loading
    setState(() {
      loading = false;
    });

    // Feedback ao usuário e limpeza dos campos
    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projeto criado com sucesso')),
      );

      projectNameController.clear();
      projectDescriptionController.clear();

      setState(() {
        _image = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao criar projeto')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tela principal de criação de projetos
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projetos'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo: nome do projeto
              const Text(
                'Nome do Projeto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: projectNameController,
                decoration: const InputDecoration(
                  hintText: 'Adicione o nome do Projeto',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Campo: descrição do projeto
              const Text(
                'Descrição do projeto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: projectDescriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Adicione uma descrição ao projeto',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // Seleção de imagem do projeto
              const Text(
                'Imagem do projeto',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // Exibe placeholder ou imagem escolhida
                  child: _image == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 40),
                              SizedBox(height: 8),
                              Text('Toque para adicionar foto'),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // Botão salvar projeto
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loading ? null : _salvarProjeto,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text('Salvar Projeto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
