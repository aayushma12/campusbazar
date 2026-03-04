import 'package:equatable/equatable.dart';

/// Domain entity for user profile.
///
/// This class is UI-agnostic and represents profile data used by use cases.
class Profile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final String? phoneNumber;
  final String? studentId;
  final String? batch;
  final String? collegeId;
  final String? university;
  final String? campus;
  final String? bio;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.phoneNumber,
    this.studentId,
    this.batch,
    this.collegeId,
    this.university,
    this.campus,
    this.bio,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        profilePicture,
        phoneNumber,
        studentId,
        batch,
        collegeId,
        university,
        campus,
        bio,
      ];
}
