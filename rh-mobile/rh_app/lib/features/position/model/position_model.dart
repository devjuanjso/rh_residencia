class Position {
  final String id;
  final String titulo;
  final String? descricao;
  final List<String> habilidadesRequeridas;
  final List<String> certificacoesRequeridas;
  final String? formacaoDesejada;

  Position({
    required this.id,
    required this.titulo,
    this.descricao,
    required this.habilidadesRequeridas,
    required this.certificacoesRequeridas,
    this.formacaoDesejada,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      habilidadesRequeridas:
          (json['habilidades_requeridas'] as List?)?.cast<String>() ?? [],
      certificacoesRequeridas:
          (json['certificacoes_requeridas'] as List?)?.cast<String>() ?? [],
      formacaoDesejada: json['formacao_desejada'],
    );
  }
}
