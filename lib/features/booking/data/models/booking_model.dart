import '../../domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required String id,
    required String requestId,
    required String tutorId,
    required String studentId,
    required double amount,
    required String status,
    required String paymentStatus,
    required String subject,
    required String? description,
    required String sessionType,
    required double hours,
    required double ratePerHour,
    required double totalAmount,
    required double netToTutor,
    required double platformFee,
        required String tutorName,
        required String studentName,
        required String transactionId,
    required DateTime createdAt,
  }) : super(
          id: id,
          requestId: requestId,
          tutorId: tutorId,
          studentId: studentId,
          amount: amount,
          status: status,
          paymentStatus: paymentStatus,
          subject: subject,
          description: description,
          sessionType: sessionType,
          hours: hours,
          ratePerHour: ratePerHour,
          totalAmount: totalAmount,
          netToTutor: netToTutor,
          platformFee: platformFee,
          tutorName: tutorName,
          studentName: studentName,
          transactionId: transactionId,
          createdAt: createdAt,
        );

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final studentRaw = json['studentId'];
    final tutorRaw = json['tutorId'];
    final student = studentRaw is Map<String, dynamic> ? studentRaw : const {};
    final tutor = tutorRaw is Map<String, dynamic> ? tutorRaw : const {};

    final status = (json['status'] ?? 'pending').toString();
    final paymentStatus = status == 'paid' ? 'paid' : 'pending';

    return BookingModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      requestId: json['requestId']?.toString() ?? '',
      tutorId: (tutor['_id'] ?? tutor['id'] ?? tutorRaw ?? '').toString(),
      studentId: (student['_id'] ?? student['id'] ?? studentRaw ?? '').toString(),
      amount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: status,
      paymentStatus: paymentStatus,
      subject: json['subject']?.toString() ?? '',
      description: json['description']?.toString(),
      sessionType: json['sessionType']?.toString() ?? 'online',
      hours: (json['hours'] as num?)?.toDouble() ?? 0,
      ratePerHour: (json['ratePerHour'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      netToTutor: (json['netToTutor'] as num?)?.toDouble() ?? 0,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0,
      tutorName: (tutor['name'] ?? json['tutorName'] ?? 'Tutor').toString(),
      studentName: (student['name'] ?? json['studentName'] ?? 'Student').toString(),
      transactionId: (json['transactionId'] ?? '').toString(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
