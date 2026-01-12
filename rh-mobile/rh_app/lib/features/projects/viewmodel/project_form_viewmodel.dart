import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rh_app/features/projects/controller/projects_controller.dart';

class ProjectViewModel extends ChangeNotifier {
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();

  File? imagem;
  bool loading = false;

  // Define a imagem selecionada para o projeto
  void setImagem(File? file) {
    imagem = file;
    notifyListeners();
  }

  // Salva um novo projeto chamando o controller e mostra feedback na tela
  Future<void> salvarProjeto(BuildContext context) async {
    loading = true;
    notifyListeners();

    final sucesso = await ProjectController.criarProjeto(
      nome: nomeController.text.trim(),
      descricao: descricaoController.text.trim(),
      imagem: imagem,
    );

    loading = false;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso ? 'Projeto criado com sucesso' : 'Erro ao criar projeto',
        ),
      ),
    );
  }

  // Libera os controllers quando o view model não for mais usado
  void disposeControllers() {
    nomeController.dispose();
    descricaoController.dispose();
  }
}
