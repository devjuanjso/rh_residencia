import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rh_app/features/projects/controller/projects_controller.dart';

class ProjectViewModel extends ChangeNotifier {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  File? imagem;
  bool loading = false;

  void setImagem(File file) {
    imagem = file;
    notifyListeners();
  }

  Future<void> salvarProjeto(BuildContext context) async {
    loading = true;
    notifyListeners();

    final sucesso = await ProjectController.criarProjeto(
      nome: nomeController.text,
      descricao: descricaoController.text,
      imagem: imagem,
    );

    loading = false;
    notifyListeners();

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projeto criado com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao criar projeto')),
      );
    }
  }
}
