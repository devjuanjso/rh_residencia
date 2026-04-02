class Recomendacao {
  final String candidaturaId;
  final String usuarioId;
  final double compatibilidade;

  const Recomendacao({
    required this.candidaturaId,
    required this.usuarioId,
    required this.compatibilidade,
  });

  factory Recomendacao.fromJson(Map<String, dynamic> json) {
    return Recomendacao(
      candidaturaId: json['candidatura_id'] as String,
      usuarioId: json['usuario_id'] as String,
      compatibilidade: (json['compatibilidade'] as num).toDouble(),
    );
  }
}