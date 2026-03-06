import 'package:equatable/equatable.dart';

/// Core product entity used throughout the products module.
class ProductEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final String categoryId;
  final String categoryName;
  final String condition;
  final String status;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final String sellerEmail;
  final String campus;
  final bool negotiable;
  final DateTime createdAt;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    required this.condition,
    required this.status,
    required this.images,
    required this.sellerId,
    required this.sellerName,
    required this.sellerEmail,
    required this.campus,
    required this.negotiable,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        categoryId,
        categoryName,
        condition,
        status,
        images,
        sellerId,
        sellerName,
        sellerEmail,
        campus,
        negotiable,
        createdAt,
      ];
}
