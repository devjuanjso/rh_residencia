import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rh_app/features/projects/controller/projects_controller.dart';

class ProjectViewModel extends ChangeNotifier {
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();

  File? imagem;
  bool loading = false;

  void setImagem(File? file) {
    imagem = file;
    notifyListeners();
  }

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

  void disposeControllers() {
    nomeController.dispose();
    descricaoController.dispose();
  }
}
