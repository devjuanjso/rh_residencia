class Position {
  final String id;
  final String projectId;
  final String titulo;
  final String descricao;
  final List<String> habilidadesRequeridas;
  final List<String> certificacoesRequeridas;
  final List<String> formacaoDesejada;

  Position({
    required this.id,
    required this.projectId,
    required this.titulo,
    required this.descricao,
    required this.habilidadesRequeridas,
    required this.certificacoesRequeridas,
    required this.formacaoDesejada,

  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'],
      projectId: json['projectId'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      habilidadesRequeridas: List<String>.from(json['habilidades_requeridas']),
      certificacoesRequeridas: List<String>.from(json['certificacoes_requeridas']),
      formacaoDesejada: List<String>.from(json['formacao_desejada']),
    );
  }
}
