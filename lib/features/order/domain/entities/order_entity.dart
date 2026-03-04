class OrderEntity {
  final String id;
  final String productId;
  final String buyerId;
  final String sellerId;
  final int quantity;
  final double totalPrice;
  final String paymentMethod;
  final String paymentStatus;
  final String deliveryNote;
  final bool acknowledgedCollegeRule;
  final String orderStatus;

  // Optional presentation-friendly fields if backend populates product
  final String productTitle;
  final String productImage;

  @Deprecated('Use totalPrice')
  final double price;
  @Deprecated('Use orderStatus')
  final String status;

  final String? rejectionReason;
  final DateTime createdAt;

  OrderEntity({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.quantity,
    required this.totalPrice,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.deliveryNote,
    required this.acknowledgedCollegeRule,
    required this.orderStatus,
    required this.productTitle,
    required this.productImage,
    required this.price,
    required this.status,
    required this.rejectionReason,
    required this.createdAt,
  });
}
