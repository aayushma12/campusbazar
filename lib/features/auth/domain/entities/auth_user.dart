import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String email;
  final String name;

  const AuthUser({required this.id, required this.email, required this.name});

  @override
  List<Object?> get props => [id, email, name];
}
