import 'package:equatable/equatable.dart';

class TutorRequestEntity extends Equatable {
  final String id;
  final String studentId;
  final String studentName;
  final String subject;
  final String description;
  final String schedule;
  final String status; // open/accepted/completed/canceled
  final DateTime createdAt;

  const TutorRequestEntity({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.subject,
    required this.description,
    required this.schedule,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        studentName,
        subject,
        description,
        schedule,
        status,
        createdAt,
      ];
}
