class Recomendacao {
  final String candidaturaId;
  final String usuarioId;
  final double compatibilidade;
  final String status;
  final String nome;
  final String email;
  final String? cargo;
  final String? senioridade;
  final String? area;
  final List<String> habilidades;
  final List<String> certificacoes;
  final String? formacao;
  final String? linkedin;
  final String? foto;
  final String? bio;

  const Recomendacao({
    required this.candidaturaId,
    required this.usuarioId,
    required this.compatibilidade,
    required this.status,
    required this.nome,
    required this.email,
    this.cargo,
    this.senioridade,
    this.area,
    this.habilidades = const [],
    this.certificacoes = const [],
    this.formacao,
    this.linkedin,
    this.foto,
    this.bio,
  });

  Recomendacao copyWith({String? status}) {
    return Recomendacao(
      candidaturaId: candidaturaId,
      usuarioId: usuarioId,
      compatibilidade: compatibilidade,
      status: status ?? this.status,
      nome: nome,
      email: email,
      cargo: cargo,
      senioridade: senioridade,
      area: area,
      habilidades: habilidades,
      certificacoes: certificacoes,
      formacao: formacao,
      linkedin: linkedin,
      foto: foto,
      bio: bio,
    );
  }

  factory Recomendacao.fromJson(Map<String, dynamic> json) {
    return Recomendacao(
      candidaturaId: json['candidatura_id'] as String,
      usuarioId: json['usuario_id'] as String,
      compatibilidade: (json['compatibilidade'] as num).toDouble(),
      status: json['status'] as String? ?? 'pendente',
      nome: json['nome'] as String? ?? 'Sem nome',
      email: json['email'] as String? ?? '',
      cargo: json['cargo'] as String?,
      senioridade: json['senioridade'] as String?,
      area: json['area'] as String?,
      habilidades: List<String>.from(json['habilidades'] ?? []),
      certificacoes: List<String>.from(json['certificacoes'] ?? []),
      formacao: json['formacao'] as String?,
      linkedin: json['linkedin'] as String?,
      foto: json['foto'] as String?,
      bio: json['bio'] as String?,
    );
  }
}