import '../../domain/entities/payment_entity.dart';

class PaymentModel extends Payment {
  const PaymentModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.amount,
    required super.transactionId,
    required super.status,
    required super.paymentMethod,
    required super.createdAt,
    super.signature,
    super.successUrl,
    super.failureUrl,
    super.productCode,
    super.signedFieldNames,
  });

  factory PaymentModel.fromInitJson(Map<String, dynamic> json, {String? productId}) {
    final totalAmountRaw = json['total_amount'] ?? json['amount'] ?? 0;
    return PaymentModel(
      id: '',
      orderId: '',
      productId: productId,
      amount: _toDouble(totalAmountRaw),
      transactionId: (json['transaction_uuid'] ?? '').toString(),
      status: PaymentStatus.pending,
      paymentMethod: 'eSewa',
      createdAt: DateTime.now(),
      signature: json['signature']?.toString(),
      successUrl: json['success_url']?.toString(),
      failureUrl: json['failure_url']?.toString(),
      productCode: json['product_code']?.toString(),
      signedFieldNames: json['signed_field_names']?.toString(),
    );
  }

  factory PaymentModel.fromTransactionJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      orderId: (json['orderId'] ?? '').toString(),
      productId: _extractProductId(json),
      amount: _toDouble(json['amount']),
      transactionId: (json['transactionUUID'] ?? json['transactionId'] ?? '').toString(),
      status: _statusFromBackend((json['status'] ?? 'pending').toString()),
      paymentMethod: (json['paymentMethod'] ?? 'eSewa').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      signature: json['signature']?.toString(),
      successUrl: json['success_url']?.toString(),
      failureUrl: json['failure_url']?.toString(),
      productCode: json['product_code']?.toString(),
      signedFieldNames: json['signed_field_names']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'amount': amount,
      'transactionId': transactionId,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'signature': signature,
      'success_url': successUrl,
      'failure_url': failureUrl,
      'product_code': productCode,
      'signed_field_names': signedFieldNames,
    };
  }

  static PaymentStatus _statusFromBackend(String value) {
    final v = value.toLowerCase();
    if (v == 'done' || v == 'success' || v == 'completed') return PaymentStatus.success;
    if (v == 'failed' || v == 'failure' || v == 'error') return PaymentStatus.failed;
    return PaymentStatus.pending;
  }

  static String? _extractProductId(Map<String, dynamic> json) {
    final p = json['productId'];
    if (p is Map<String, dynamic>) {
      return (p['_id'] ?? p['id'])?.toString();
    }
    return p?.toString();
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '0') ?? 0;
  }
}
