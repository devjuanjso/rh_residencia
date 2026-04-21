import 'package:flutter/material.dart';
import '../controller/candidatura_controller.dart';
import '../model/candidatura_model.dart';

class CandidaturaListViewModel extends ChangeNotifier {
  final CandidaturaController _controller = CandidaturaController();

  List<Candidatura> _candidaturas = [];
  bool loading = false;
  String? erro;

  List<Candidatura> get candidaturas => _candidaturas;

  String searchQuery = '';
  String filtroStatus = 'Todos'; // 'Todos' | 'pendente' | 'aceito' | 'rejeitado'

  List<Candidatura> get filtradas {
    return _candidaturas.where((c) {
      final matchesSearch = searchQuery.isEmpty ||
          c.projetoNome.toLowerCase().contains(searchQuery.toLowerCase()) ||
          c.vagaTitulo.toLowerCase().contains(searchQuery.toLowerCase());

      final matchesStatus = filtroStatus == 'Todos' || c.status == filtroStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  Future<void> carregar() async {
    loading = true;
    erro = null;
    notifyListeners();

    try {
      _candidaturas = await _controller.minhasCandidaturasCompletas();
    } catch (e) {
      erro = 'Erro ao carregar candidaturas';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setSearch(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setFiltroStatus(String status) {
    filtroStatus = status;
    notifyListeners();
  }
}