import 'package:flutter/material.dart';
import 'package:rh_app/features/position/model/position_model.dart';
import '../controller/position_controller.dart';

class PositionListViewModel extends ChangeNotifier {
  List<Position> positions = [];
  bool isLoading = false;
  String errorMessage = '';

  // Carrega a lista de vagas, com opção de filtrar por projeto
  Future<void> loadPositions({String? projetoId}) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      positions = await PositionController.list(projetoId: projetoId);
    } catch (e) {
      errorMessage = 'Erro ao carregar vagas';
    }

    isLoading = false;
    notifyListeners();
  }

  // Remove uma vaga específica da lista pelo seu ID
  Future<void> removePosition(String id) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      await PositionController.delete(id);
      positions.removeWhere((vaga) => vaga.id == id);
    } catch (e) {
      errorMessage = 'Erro ao deletar a vaga';
    }

    isLoading = false;
    notifyListeners();
  }
}