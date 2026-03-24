class Project {
  final String id;
  final String nome;
  final String descricao;
  final String? imagem;
  final String? tipo;
  final bool rascunho;
  final DateTime? dataInicio;
  final String? criadoPorNome;

  Project({
    required this.id,
    required this.nome,
    required this.descricao,
    this.imagem,
    this.tipo,
    this.rascunho = true,
    this.dataInicio,
    this.criadoPorNome,
    
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      imagem: json['imagem'],
      tipo: json['tipo'],
      rascunho: json['rascunho'] ?? true,
      dataInicio: json['data_inicio'] != null
          ? DateTime.tryParse(json['data_inicio'])
          : null,
      criadoPorNome: json['criado_por_nome'],
    );
  }
}