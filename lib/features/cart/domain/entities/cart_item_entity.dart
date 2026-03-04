import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final String id;
  final String productId;
  final String productTitle;
  final double productPrice;
  final String productImage;
  final int quantity;
  final String sellerId;
  final bool isAvailable;

  const CartItem({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    required this.productImage,
    required this.quantity,
    required this.sellerId,
    required this.isAvailable,
  });

  CartItem copyWith({
    String? id,
    String? productId,
    String? productTitle,
    double? productPrice,
    String? productImage,
    int? quantity,
    String? sellerId,
    bool? isAvailable,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productTitle: productTitle ?? this.productTitle,
      productPrice: productPrice ?? this.productPrice,
      productImage: productImage ?? this.productImage,
      quantity: quantity ?? this.quantity,
      sellerId: sellerId ?? this.sellerId,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productTitle,
        productPrice,
        productImage,
        quantity,
        sellerId,
        isAvailable,
      ];
}
