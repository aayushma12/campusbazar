class TransactionEntity {
  final String id;
  final List<String> productIds;
  final String buyerId;
  final String sellerId;
  final double amount;
  final String status;
  final String transactionUUID;
  final DateTime createdAt;

  TransactionEntity({
    required this.id,
    required this.productIds,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    required this.status,
    required this.transactionUUID,
    required this.createdAt,
  });
}
