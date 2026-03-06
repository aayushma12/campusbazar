import '../../domain/entities/tutor_request_entity.dart';

class TutorRequestModel extends TutorRequestEntity {
  const TutorRequestModel({
    required super.id,
    required super.studentId,
    required super.studentName,
    required super.subject,
    required super.description,
    required super.schedule,
    required super.status,
    required super.createdAt,
  });

  factory TutorRequestModel.fromJson(Map<String, dynamic> json) {
    final studentRaw = json['studentId'];
    final studentMap = studentRaw is Map<String, dynamic> ? studentRaw : const {};

    return TutorRequestModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      studentId: (studentMap['_id'] ?? studentMap['id'] ?? studentRaw ?? '').toString(),
      studentName: (studentMap['name'] ?? json['studentName'] ?? 'Student').toString(),
      subject: (json['subject'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      schedule: (json['preferredTime'] ?? json['schedule'] ?? '').toString(),
      status: _mapStatus((json['status'] ?? 'pending').toString()),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toRequestJson() {
    return {
      'subject': subject,
      'topic': subject,
      'description': description,
      'preferredTime': schedule,
    };
  }

  static String _mapStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'open';
      case 'accepted':
        return 'accepted';
      case 'completed':
        return 'completed';
      case 'cancelled':
      case 'canceled':
        return 'canceled';
      default:
        return status;
    }
  }
}
