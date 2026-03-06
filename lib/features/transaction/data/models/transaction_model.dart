import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  TransactionModel({
    required String id,
    required List<String> productIds,
    required String buyerId,
    required String sellerId,
    required double amount,
    required String status,
    required String transactionUUID,
    required DateTime createdAt,
  }) : super(
          id: id,
          productIds: productIds,
          buyerId: buyerId,
          sellerId: sellerId,
          amount: amount,
          status: status,
          transactionUUID: transactionUUID,
          createdAt: createdAt,
        );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      productIds: (json['productIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      buyerId: json['buyerId']?.toString() ?? '',
      sellerId: json['sellerId']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'pending',
      transactionUUID: json['transactionUUID']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
