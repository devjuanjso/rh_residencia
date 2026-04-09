class ProfileModel {
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String nomeCompleto;
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
    required this.firstName,
    required this.lastName,
    required this.nomeCompleto,
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
      firstName: json["first_name"] ?? '',
      lastName: json["last_name"] ?? '',
      nomeCompleto: json["nome_completo"] ?? json["username"], // fallback para username
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