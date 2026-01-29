import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rh_app/features/projects/controller/project_controller.dart';

class ProjectFormViewModel extends ChangeNotifier {
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  
  File? imagem;
  bool loading = false;
  String? projetoId;
  bool manterImagemAtual = false;
  String? imagemUrlAtual;
  bool dadosCarregados = false;

  // Carrega dados de um projeto para edição
  void carregarProjetoParaEdicao({
    required String id,
    required String nome,
    required String descricao,
    String? imagemUrl,
  }) {
    projetoId = id;
    nomeController.text = nome;
    descricaoController.text = descricao;
    imagemUrlAtual = imagemUrl;
    manterImagemAtual = true;
    dadosCarregados = true;
    _safeNotifyListeners();
  }

  // Limpa todos os dados do formulário
  void limparDados() {
    nomeController.clear();
    descricaoController.clear();
    imagem = null;
    projetoId = null;
    manterImagemAtual = false;
    imagemUrlAtual = null;
    dadosCarregados = false;
    _safeNotifyListeners();
  }

  // Define imagem selecionada pelo usuário
  void setImagem(File? file) {
    imagem = file;
    manterImagemAtual = false;
    _safeNotifyListeners();
  }

  // Define se mantém imagem atual na edição
  void setManterImagemAtual(bool value) {
    manterImagemAtual = value;
    if (value) {
      imagem = null;
    }
    _safeNotifyListeners();
  }

  // Salva projeto (criação ou edição)
  Future<String?> salvarProjeto(BuildContext context) async {
    loading = true;
    _safeNotifyListeners();

    try {
      String? projetoIdCriado;

      if (projetoId != null) {
        final sucesso = await ProjectController.editarProjeto(
          projetoId: projetoId!,
          nome: nomeController.text.trim(),
          descricao: descricaoController.text.trim(),
          imagem: imagem,
          manterImagemAtual: manterImagemAtual,
        );
        
        if (sucesso) {
          projetoIdCriado = projetoId;
        }
      } else {
        projetoIdCriado = await ProjectController.criarProjeto(
          nome: nomeController.text.trim(),
          descricao: descricaoController.text.trim(),
          imagem: imagem,
        );
      }

      loading = false;
      _safeNotifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            projetoIdCriado != null 
                ? (projetoId != null ? 'Projeto atualizado com sucesso' : 'Projeto criado com sucesso')
                : (projetoId != null ? 'Erro ao atualizar projeto' : 'Erro ao criar projeto'),
          ),
          backgroundColor: projetoIdCriado != null ? Colors.green : Colors.red,
        ),
      );

      return projetoIdCriado;
    } catch (e) {
      loading = false;
      _safeNotifyListeners();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $e'),
          backgroundColor: Colors.red,
        ),
      );
      
      return null;
    }
  }

  // Atualização parcial sem contexto de UI
  Future<bool> atualizarProjetoParcial() async {
    if (projetoId == null) return false;

    loading = true;
    _safeNotifyListeners();

    try {
      final sucesso = await ProjectController.atualizarProjetoParcial(
        projetoId: projetoId!,
        nome: nomeController.text.trim(),
        descricao: descricaoController.text.trim(),
        imagem: imagem,
      );

      loading = false;
      _safeNotifyListeners();
      return sucesso;
    } catch (e) {
      loading = false;
      _safeNotifyListeners();
      return false;
    }
  }

  // Busca projeto por ID para preencher formulário
  Future<void> buscarProjetoParaEdicao(String id) async {
    loading = true;
    _safeNotifyListeners();

    try {
      final projeto = await ProjectController.buscarProjetoPorId(id);
      
      if (projeto != null) {
        carregarProjetoParaEdicao(
          id: projeto.id,
          nome: projeto.nome,
          descricao: projeto.descricao,
          imagemUrl: projeto.imagem,
        );
      } else {
        limparDados();
      }
    } catch (e) {
      limparDados();
    } finally {
      loading = false;
      _safeNotifyListeners();
    }
  }

  // Verifica se há alterações não salvas
  bool get hasChanges {
    return nomeController.text.isNotEmpty || 
           descricaoController.text.isNotEmpty ||
           imagem != null ||
           manterImagemAtual != true;
  }

  // Valida se campos obrigatórios estão preenchidos
  bool get isValid {
    return nomeController.text.trim().isNotEmpty &&
           descricaoController.text.trim().isNotEmpty;
  }

  // Retorna título da tela baseado no contexto
  String get screenTitle {
    return projetoId != null ? 'Editar Projeto' : 'Novo Projeto';
  }

  // Retorna texto do botão principal
  String get actionButtonText {
    return projetoId != null ? 'Atualizar' : 'Criar';
  }

  // Libera recursos dos controllers
  void disposeControllers() {
    nomeController.dispose();
    descricaoController.dispose();
  }

  // Método seguro para notificar listeners
  void _safeNotifyListeners() {
    if (hasListeners) {
      notifyListeners();
    }
  }
}