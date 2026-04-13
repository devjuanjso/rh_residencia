class Candidatura {
  final String id;
  final String status;
  final DateTime data;
  final String vagaId;
  final String vagaTitulo;
  final String projetoId;
  final String projetoNome;
  final String? projetoImagem;

  Candidatura({
    required this.id,
    required this.status,
    required this.data,
    required this.vagaId,
    required this.vagaTitulo,
    required this.projetoId,
    required this.projetoNome,
    this.projetoImagem,
  });

  factory Candidatura.fromJson(Map<String, dynamic> json) => Candidatura(
        id: json['id'] ?? '',
        status: json['status'] ?? 'pendente',
        data: DateTime.tryParse(json['data'] ?? '') ?? DateTime.now(),
        vagaId: json['vaga_id'] ?? '',
        vagaTitulo: json['vaga_titulo'] ?? '',
        projetoId: json['projeto_id'] ?? '',
        projetoNome: json['projeto_nome'] ?? '',
        projetoImagem: json['projeto_imagem'],
      );
}