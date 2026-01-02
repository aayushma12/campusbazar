import 'package:campus_bazar/features/auth/domain/entities/user.dart';
import 'package:hive/hive.dart';

part 'user_model.g.dart'; // <- THIS IS REQUIRED

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  UserModel({
    this.userId,
    required this.fullName,
    required this.email,
    required this.password,
  });

  User toEntity() => User(
        id: userId ?? '',
        name: fullName,
        email: email,
        token: '', // generate token in repository
      );
}
