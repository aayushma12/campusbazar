import 'package:hive/hive.dart';
import '../../domain/entities/profile_entity.dart';

/// Data model used in data layer and local cache.
///
/// It extends [Profile] so repository can return it as domain entity.
class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.profilePicture,
    super.phoneNumber,
    super.studentId,
    super.batch,
    super.collegeId,
    super.university,
    super.campus,
    super.bio,
  });

  /// Parses backend response for GET and PATCH profile APIs.
  /// Backend returns either:
  /// - direct object { id, name, ... }
  /// - wrapped object { data: { id, name, ... } }
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final dynamic data = json['data'] ?? json;
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};

    return ProfileModel(
      id: (map['id'] ?? map['_id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      profilePicture: map['profilePicture']?.toString(),
      phoneNumber: map['phoneNumber']?.toString(),
      studentId: map['studentId']?.toString(),
      batch: map['batch']?.toString(),
      collegeId: map['collegeId']?.toString(),
      university: map['university']?.toString(),
      campus: map['campus']?.toString(),
      bio: map['bio']?.toString(),
    );
  }

  factory ProfileModel.fromMap(Map<dynamic, dynamic> map) {
    return ProfileModel(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      profilePicture: map['profilePicture']?.toString(),
      phoneNumber: map['phoneNumber']?.toString(),
      studentId: map['studentId']?.toString(),
      batch: map['batch']?.toString(),
      collegeId: map['collegeId']?.toString(),
      university: map['university']?.toString(),
      campus: map['campus']?.toString(),
      bio: map['bio']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'phoneNumber': phoneNumber,
      'studentId': studentId,
      'batch': batch,
      'collegeId': collegeId,
      'university': university,
      'campus': campus,
      'bio': bio,
    };
  }
}

/// Manual Hive adapter for profile cache.
/// Keeping this manual avoids a required build_runner step for this feature.
class ProfileModelAdapter extends TypeAdapter<ProfileModel> {
  @override
  final int typeId = 1;

  @override
  ProfileModel read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final email = reader.readString();
    final profilePicture = reader.readString();
    final phoneNumber = reader.readString();
    final studentId = reader.readString();
    final batch = reader.readString();
    final collegeId = reader.readString();
    final university = reader.readString();
    final campus = reader.readString();
    final bio = reader.readString();

    return ProfileModel(
      id: id,
      name: name,
      email: email,
      profilePicture: profilePicture.isEmpty ? null : profilePicture,
      phoneNumber: phoneNumber.isEmpty ? null : phoneNumber,
      studentId: studentId.isEmpty ? null : studentId,
      batch: batch.isEmpty ? null : batch,
      collegeId: collegeId.isEmpty ? null : collegeId,
      university: university.isEmpty ? null : university,
      campus: campus.isEmpty ? null : campus,
      bio: bio.isEmpty ? null : bio,
    );
  }

  @override
  void write(BinaryWriter writer, ProfileModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeString(obj.email)
      ..writeString(obj.profilePicture ?? '')
      ..writeString(obj.phoneNumber ?? '')
      ..writeString(obj.studentId ?? '')
      ..writeString(obj.batch ?? '')
      ..writeString(obj.collegeId ?? '')
      ..writeString(obj.university ?? '')
      ..writeString(obj.campus ?? '')
      ..writeString(obj.bio ?? '');
  }
}
