class UserModel {
  final String id;
  final String username;
  final String email;
  final String role;
  final String accessToken;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.accessToken,
  });
}