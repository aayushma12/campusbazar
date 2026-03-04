import '../../domain/entities/wishlist_item_entity.dart';

class WishlistModel extends WishlistItem {
  const WishlistModel({
    required super.id,
    required super.productId,
    required super.productTitle,
    required super.productPrice,
    required super.productImage,
    required super.addedAt,
  });

  /// Backend shape from GET /api/v1/wishlist
  /// item = {
  ///   _id,
  ///   createdAt,
  ///   productId: {
  ///     _id, title, price, images[]
  ///   }
  /// }
  factory WishlistModel.fromJson(Map<String, dynamic> json) {
    final product = (json['productId'] as Map<String, dynamic>? ?? <String, dynamic>{});

    return WishlistModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      productId: (product['_id'] ?? product['id'] ?? '').toString(),
      productTitle: (product['title'] ?? '').toString(),
      productPrice: (product['price'] as num?)?.toDouble() ?? 0,
      productImage: (product['images'] as List<dynamic>? ?? const []).isNotEmpty
          ? (product['images'] as List<dynamic>).first.toString()
          : '',
      addedAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  factory WishlistModel.optimistic({
    required String productId,
    required String title,
    required double price,
    required String image,
  }) {
    return WishlistModel(
      id: 'temp-$productId',
      productId: productId,
      productTitle: title,
      productPrice: price,
      productImage: image,
      addedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'productTitle': productTitle,
        'productPrice': productPrice,
        'productImage': productImage,
        'addedAt': addedAt.toIso8601String(),
      };
}
