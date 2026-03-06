import 'package:equatable/equatable.dart';

class WishlistItem extends Equatable {
  final String id;
  final String productId;
  final String productTitle;
  final double productPrice;
  final String productImage;
  final DateTime addedAt;

  const WishlistItem({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.productPrice,
    required this.productImage,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [id, productId, productTitle, productPrice, productImage, addedAt];
}
