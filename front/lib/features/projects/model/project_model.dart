class Project {
  final String id;
  final String nome;
  final String descricao;
  final String? imagem;
  final String? tipo;
  final String status; // 'rascunho', 'publicado', 'encerrado'
  final DateTime? dataInicio;
  final String? criadoPorNome;

  Project({
    required this.id,
    required this.nome,
    required this.descricao,
    this.imagem,
    this.tipo,
    this.status = 'rascunho',
    this.dataInicio,
    this.criadoPorNome,
  });

  bool get isRascunho => status == 'rascunho';
  bool get isPublicado => status == 'publicado';
  bool get isEncerrado => status == 'encerrado';

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      imagem: json['imagem'],
      tipo: json['tipo'],
      status: json['status'] ?? 'rascunho',
      dataInicio: json['data_inicio'] != null
          ? DateTime.tryParse(json['data_inicio'])
          : null,
      criadoPorNome: json['criado_por_nome'],
    );
  }
}
