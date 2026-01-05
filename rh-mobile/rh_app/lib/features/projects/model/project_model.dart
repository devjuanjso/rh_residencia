class Project {
  final String id;
  final String nome;
  final String descricao;
  final String? imagem;

  Project({
    required this.id,
    required this.nome,
    required this.descricao,
    this.imagem,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'],
      imagem: json['imagem'],
    );
  }
}
