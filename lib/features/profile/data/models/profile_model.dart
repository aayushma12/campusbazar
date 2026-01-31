import 'package:hive/hive.dart';
import '../../domain/entities/profile_entity.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 1)
class ProfileModel extends Profile {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String email;
  @override
  @HiveField(3)
  final String? profilePicture;
  @override
  @HiveField(4)
  final String? phoneNumber;
  @override
  @HiveField(5)
  final String? studentId;
  @override
  @HiveField(6)
  final String? batch;
  @override
  @HiveField(7)
  final String? collegeId;

  const ProfileModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.phoneNumber,
    this.studentId,
    this.batch,
    this.collegeId,
  }) : super(
          id: id,
          name: name,
          email: email,
          profilePicture: profilePicture,
          phoneNumber: phoneNumber,
          studentId: studentId,
          batch: batch,
          collegeId: collegeId,
        );

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return ProfileModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePicture: data['profilePicture'],
      phoneNumber: data['phoneNumber'],
      studentId: data['studentId'],
      batch: data['batch'],
      collegeId: data['collegeId'],
    );
  }
}
