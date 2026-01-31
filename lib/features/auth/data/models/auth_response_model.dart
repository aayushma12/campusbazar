class AuthResponseModel {
  final String userId;
  final String name;
  final String email;
  final String token;

  AuthResponseModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return AuthResponseModel(
      userId: user['id']?.toString() ?? '', // convert id to string
      name: user['name'] ?? '',
      email: user['email'] ?? '',
      token: json['accessToken'] ?? json['token'] ?? '',
    );
  }
}
