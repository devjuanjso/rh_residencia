class ChoiceOption {
  final String value;
  final String label;

  const ChoiceOption({required this.value, required this.label});

  factory ChoiceOption.fromJson(Map<String, dynamic> json) => ChoiceOption(
        value: json['value'] as String,
        label: json['label'] as String,
      );
}

class PositionChoices {
  final List<ChoiceOption> senioridades;
  final List<ChoiceOption> areas;

  const PositionChoices({required this.senioridades, required this.areas});

  factory PositionChoices.fromJson(Map<String, dynamic> json) => PositionChoices(
        senioridades: (json['senioridades'] as List)
            .map((e) => ChoiceOption.fromJson(e))
            .toList(),
        areas: (json['areas'] as List)
            .map((e) => ChoiceOption.fromJson(e))
            .toList(),
      );
}

class Position {
  final String id;
  final String titulo;
  final String? senioridade;
  final String? area;
  final List<String> habilidadesRequeridas;
  final List<String> certificacoesRequeridas;
  final String? formacaoDesejada;
  final String projetoId;

  Position({
    required this.id,
    required this.titulo,
    this.senioridade,
    this.area,
    required this.habilidadesRequeridas,
    required this.certificacoesRequeridas,
    this.formacaoDesejada,
    required this.projetoId,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      senioridade: json['senioridade'],
      area: json['area'],
      habilidadesRequeridas:
          (json['habilidades_requeridas'] as List?)?.cast<String>() ?? [],
      certificacoesRequeridas:
          (json['certificacoes_requeridas'] as List?)?.cast<String>() ?? [],
      formacaoDesejada: json['formacao_desejada'],
      projetoId: json['projeto'] ?? '',
    );
  }
}