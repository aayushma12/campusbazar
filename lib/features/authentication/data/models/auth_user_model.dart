import 'package:hive/hive.dart';

import '../../domain/entities/auth_user.dart';

/// Data model that extends the domain entity and can be persisted in Hive.
class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    super.university,
    super.campus,
    super.profilePicture,
  });

  factory AuthUserModel.fromBackendJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'user').toString(),
      university: json['university']?.toString(),
      campus: json['campus']?.toString(),
      profilePicture: json['profilePicture']?.toString(),
    );
  }

  factory AuthUserModel.fromMap(Map<dynamic, dynamic> map) {
    return AuthUserModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      role: (map['role'] ?? 'user').toString(),
      university: map['university']?.toString(),
      campus: map['campus']?.toString(),
      profilePicture: map['profilePicture']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'university': university,
      'campus': campus,
      'profilePicture': profilePicture,
    };
  }
}

/// Manual adapter to avoid code generation and keep onboarding simple.
class AuthUserModelAdapter extends TypeAdapter<AuthUserModel> {
  @override
  final int typeId = 12;

  @override
  AuthUserModel read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final email = reader.readString();
    final role = reader.readString();
    final university = reader.readString();
    final campus = reader.readString();
    final profilePicture = reader.readString();

    return AuthUserModel(
      id: id,
      name: name,
      email: email,
      role: role,
      university: university.isEmpty ? null : university,
      campus: campus.isEmpty ? null : campus,
      profilePicture: profilePicture.isEmpty ? null : profilePicture,
    );
  }

  @override
  void write(BinaryWriter writer, AuthUserModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeString(obj.email)
      ..writeString(obj.role)
      ..writeString(obj.university ?? '')
      ..writeString(obj.campus ?? '')
      ..writeString(obj.profilePicture ?? '');
  }
}
