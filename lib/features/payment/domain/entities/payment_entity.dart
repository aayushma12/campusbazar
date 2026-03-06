import 'package:equatable/equatable.dart';

enum PaymentStatus { pending, success, failed }

enum PaymentFlowType { product, cart, cartItem, booking }

class Payment extends Equatable {
  final String id;
  final String orderId;
  final String? productId;
  final double amount;
  final String transactionId;
  final PaymentStatus status;
  final String paymentMethod;
  final DateTime createdAt;

  // eSewa redirect payload fields for initialization flow
  final String? signature;
  final String? successUrl;
  final String? failureUrl;
  final String? productCode;
  final String? signedFieldNames;

  const Payment({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.amount,
    required this.transactionId,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    this.signature,
    this.successUrl,
    this.failureUrl,
    this.productCode,
    this.signedFieldNames,
  });

  bool get isSuccessful => status == PaymentStatus.success;

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        amount,
        transactionId,
        status,
        paymentMethod,
        createdAt,
        signature,
        successUrl,
        failureUrl,
        productCode,
        signedFieldNames,
      ];
}
