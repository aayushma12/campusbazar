import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final String? phoneNumber;
  final String? studentId;
  final String? batch;
  final String? collegeId;

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.phoneNumber,
    this.studentId,
    this.batch,
    this.collegeId,
  });

  @override
  List<Object?> get props => [id, name, email, profilePicture, phoneNumber, studentId, batch, collegeId];
}
