class ProfileModel {
  final String id;
  final String username;
  final String email;
  final String role;
  final String? cargo;
  final String? senioridade;
  final String? area;
  final List<String> habilidades;
  final List<String> certificacoes;
  final String? formacao;
  final String? foto;
  final String? bio;
  final String? linkedin;

  ProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.cargo,
    this.senioridade,
    this.area,
    required this.habilidades,
    required this.certificacoes,
    this.formacao,
    this.foto,
    this.bio,
    this.linkedin,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json["id"],
      username: json["username"],
      email: json["email"],
      role: json["role"],
      cargo: json["cargo"],
      senioridade: json["senioridade"],
      area: json["area"],
      habilidades: List<String>.from(json["habilidades"] ?? []),
      certificacoes: List<String>.from(json["certificacoes"] ?? []),
      formacao: json["formacao"],
      foto: json["foto"],
      bio: json["bio"],
      linkedin: json["linkedin"],
    );
  }
}