import '../../domain/entities/order_entity.dart';

class OrderModel extends OrderEntity {
  OrderModel({
    required String id,
    required String productId,
    required String buyerId,
    required String sellerId,
    required int quantity,
    required double totalPrice,
    required String paymentMethod,
    required String paymentStatus,
    required String deliveryNote,
    required bool acknowledgedCollegeRule,
    required String orderStatus,
    required String productTitle,
    required String productImage,
    required double price,
    required String status,
    required String? rejectionReason,
    required DateTime createdAt,
  }) : super(
          id: id,
          productId: productId,
          buyerId: buyerId,
          sellerId: sellerId,
          quantity: quantity,
          totalPrice: totalPrice,
          paymentMethod: paymentMethod,
          paymentStatus: paymentStatus,
          deliveryNote: deliveryNote,
          acknowledgedCollegeRule: acknowledgedCollegeRule,
          orderStatus: orderStatus,
          productTitle: productTitle,
          productImage: productImage,
          price: price,
          status: status,
          rejectionReason: rejectionReason,
          createdAt: createdAt,
        );

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final orderItems = (json['orderItems'] as List?)
        ?.whereType<Map<String, dynamic>>()
        .toList() ??
      const <Map<String, dynamic>>[];
    final firstItem = orderItems.isNotEmpty ? orderItems.first : const <String, dynamic>{};

    final dynamic product = json['productId'];
    final dynamic productFromItems = firstItem['product'];
    final productMap = product is Map<String, dynamic>
      ? product
      : (productFromItems is Map<String, dynamic> ? productFromItems : const <String, dynamic>{});
    final resolvedProductId = productMap.isNotEmpty
        ? (productMap['_id'] ?? productMap['id'] ?? '').toString()
        : product?.toString() ?? '';

    final resolvedPrice = (json['totalPrice'] as num?)?.toDouble() ??
      (firstItem['totalPrice'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
      (firstItem['unitPrice'] as num?)?.toDouble() ??
        (productMap['price'] as num?)?.toDouble() ??
        0;

    final resolvedQuantity = (json['quantity'] as num?)?.toInt() ??
      (firstItem['quantity'] as num?)?.toInt() ??
      1;

    return OrderModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      productId: resolvedProductId,
      buyerId: (json['buyerId'] is Map<String, dynamic>)
          ? (json['buyerId']['_id'] ?? json['buyerId']['id'] ?? '').toString()
          : json['buyerId']?.toString() ?? '',
      sellerId: (json['sellerId'] is Map<String, dynamic>)
          ? (json['sellerId']['_id'] ?? json['sellerId']['id'] ?? '').toString()
          : json['sellerId']?.toString() ?? '',
      quantity: resolvedQuantity,
      totalPrice: resolvedPrice,
      paymentMethod: json['paymentMethod']?.toString() ?? 'eSewa',
      paymentStatus: json['paymentStatus']?.toString() ?? 'Pending',
      deliveryNote: json['deliveryNote']?.toString() ??
          'Students must receive the product within the college community premises.',
      acknowledgedCollegeRule: (json['acknowledgedCollegeRule'] ?? true) as bool,
      orderStatus: json['orderStatus']?.toString() ?? json['status']?.toString() ?? 'pending',
      productTitle: productMap['title']?.toString() ?? '',
      productImage: (productMap['images'] as List<dynamic>? ?? const []).isNotEmpty
          ? (productMap['images'] as List<dynamic>).first.toString()
          : '',
      price: resolvedPrice,
      status: json['status']?.toString() ?? json['orderStatus']?.toString() ?? 'pending',
      rejectionReason: json['rejectionReason']?.toString(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
