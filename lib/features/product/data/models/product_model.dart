// ignore: unused_import
import '../../domain/entities/product_entity.dart';

class ProductModel extends Product {
  ProductModel({
    required String id,
    required String title,
    required String description,
    required double price,
    required bool negotiable,
    required String condition,
    required String categoryId,
    required String campus,
    required List<String> images,
    required String status,
    required String ownerId,
    required int views,
    required DateTime createdAt,
  }) : super(
          id: id,
          title: title,
          description: description,
          price: price,
          negotiable: negotiable,
          condition: condition,
          categoryId: categoryId,
          campus: campus,
          images: images,
          status: status,
          ownerId: ownerId,
          views: views,
          createdAt: createdAt,
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 0.0,
      negotiable: json['negotiable'] ?? false,
      condition: json['condition'] ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      campus: json['campus'] ?? '',
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      status: json['status'] ?? '',
      ownerId: json['ownerId']?.toString() ?? '',
      views: json['views'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'negotiable': negotiable,
      'condition': condition,
      'categoryId': categoryId,
      'campus': campus,
      'images': images,
      'status': status,
      'ownerId': ownerId,
      'views': views,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
