import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required String id,
    required String productId,
    required String productTitle,
    required double productPrice,
    required String productImage,
    required int quantity,
    required String sellerId,
    required bool isAvailable,
  }) : super(
          id: id,
          productId: productId,
          productTitle: productTitle,
          productPrice: productPrice,
          productImage: productImage,
          quantity: quantity,
          sellerId: sellerId,
          isAvailable: isAvailable,
        );

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['productId'] is Map<String, dynamic> ? json['productId'] as Map<String, dynamic> : const {};
    final images = product['images'] is List<dynamic> ? product['images'] as List<dynamic> : const [];
    final status = product['status']?.toString().toLowerCase();

    return CartItemModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      productId: product['_id']?.toString() ?? json['productId']?.toString() ?? '',
      productTitle: product['title']?.toString() ?? json['title']?.toString() ?? 'Item',
      productPrice:
          (product['price'] != null) ? (product['price'] as num).toDouble() : ((json['price'] as num?)?.toDouble() ?? 0.0),
      productImage: images.isNotEmpty ? images.first.toString() : (json['image']?.toString() ?? ''),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      sellerId: product['ownerId']?.toString() ?? product['sellerId']?.toString() ?? json['sellerId']?.toString() ?? '',
      isAvailable: status == null ? true : status == 'available',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productTitle': productTitle,
      'productPrice': productPrice,
      'productImage': productImage,
      'quantity': quantity,
      'sellerId': sellerId,
      'isAvailable': isAvailable,
    };
  }

  factory CartItemModel.fromEntity(CartItem item) {
    return CartItemModel(
      id: item.id,
      productId: item.productId,
      productTitle: item.productTitle,
      productPrice: item.productPrice,
      productImage: item.productImage,
      quantity: item.quantity,
      sellerId: item.sellerId,
      isAvailable: item.isAvailable,
    );
  }
}
