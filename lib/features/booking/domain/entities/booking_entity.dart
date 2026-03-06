import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String id;
  final String requestId;
  final String tutorId;
  final String studentId;
  final double amount;
  final String status;
  final String paymentStatus;

  // Additional details kept for richer UI (still domain-safe)
  final String subject;
  final String? description;
  final String sessionType;
  final double hours;
  final double ratePerHour;
  final double totalAmount;
  final double netToTutor;
  final double platformFee;
  final String tutorName;
  final String studentName;
  final String transactionId;

  final DateTime createdAt;

  const BookingEntity({
    required this.id,
    required this.requestId,
    required this.tutorId,
    required this.studentId,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    required this.subject,
    required this.description,
    required this.sessionType,
    required this.hours,
    required this.ratePerHour,
    required this.totalAmount,
    required this.netToTutor,
    required this.platformFee,
    required this.tutorName,
    required this.studentName,
    required this.transactionId,
    required this.createdAt,
  });

  bool get canPay => paymentStatus == 'pending' && (status == 'pending' || status == 'awaiting_payment');
  bool get canCancel => status == 'pending' || status == 'awaiting_payment';

  @override
  List<Object?> get props => [
        id,
        requestId,
        tutorId,
        studentId,
        amount,
        status,
        paymentStatus,
        subject,
        description,
        sessionType,
        hours,
        ratePerHour,
        totalAmount,
        netToTutor,
        platformFee,
        tutorName,
        studentName,
        transactionId,
        createdAt,
      ];
}
