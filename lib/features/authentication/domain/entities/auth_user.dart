import 'package:equatable/equatable.dart';

/// Core authenticated user entity used by the domain and presentation layers.
class AuthUser extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? university;
  final String? campus;
  final String? profilePicture;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.university,
    this.campus,
    this.profilePicture,
  });

  @override
  List<Object?> get props => [id, name, email, role, university, campus, profilePicture];
}
