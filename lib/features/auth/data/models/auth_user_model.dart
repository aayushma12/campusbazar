import 'package:hive/hive.dart';
import '../../domain/entities/auth_user.dart';

part 'auth_user_model.g.dart';

@HiveType(typeId: 0)
class AuthUserModel extends AuthUser {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String email;
  @override
  @HiveField(2)
  final String name;
  @override
  @HiveField(3)
  final String token; // Store token here for easy caching

  const AuthUserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.token,
  }) : super(id: id, email: email, name: name,token: token);

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return AuthUserModel(
      id: user['_id']?.toString() ?? user['id']?.toString() ?? '',
      email: user['email'] ?? '',
      name: user['name'] ?? '',
      token: json['accessToken'] ?? json['token'] ?? '',
    );
  }
}
