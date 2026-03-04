import '../../domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.categoryId,
    required super.categoryName,
    required super.condition,
    required super.status,
    required super.images,
    required super.sellerId,
    required super.sellerName,
    required super.sellerEmail,
    required super.campus,
    required super.negotiable,
    required super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final owner = json['ownerId'];
    final category = json['categoryId'];

    final ownerId = owner is Map<String, dynamic>
        ? (owner['_id'] ?? owner['id'] ?? '').toString()
        : (owner ?? '').toString();
    final ownerName = owner is Map<String, dynamic> ? (owner['name'] ?? '').toString() : '';
    final ownerEmail = owner is Map<String, dynamic> ? (owner['email'] ?? '').toString() : '';

    final categoryId = category is Map<String, dynamic>
        ? (category['_id'] ?? category['id'] ?? '').toString()
        : (category ?? '').toString();
    final categoryName = category is Map<String, dynamic> ? (category['name'] ?? '').toString() : '';

    return ProductModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      categoryId: categoryId,
      categoryName: categoryName,
      condition: (json['condition'] ?? '').toString(),
      status: (json['status'] ?? 'available').toString(),
      images: (json['images'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      sellerId: ownerId,
      sellerName: ownerName,
      sellerEmail: ownerEmail,
      campus: (json['campus'] ?? '').toString(),
      negotiable: (json['negotiable'] ?? false) as bool,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  factory ProductModel.fromMap(Map<dynamic, dynamic> map) {
    return ProductModel(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0,
      categoryId: (map['categoryId'] ?? '').toString(),
      categoryName: (map['categoryName'] ?? '').toString(),
      condition: (map['condition'] ?? '').toString(),
      status: (map['status'] ?? 'available').toString(),
      images: (map['images'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      sellerId: (map['sellerId'] ?? '').toString(),
      sellerName: (map['sellerName'] ?? '').toString(),
      sellerEmail: (map['sellerEmail'] ?? '').toString(),
      campus: (map['campus'] ?? '').toString(),
      negotiable: (map['negotiable'] ?? false) as bool,
      createdAt: DateTime.tryParse((map['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'condition': condition,
      'status': status,
      'images': images,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerEmail': sellerEmail,
      'campus': campus,
      'negotiable': negotiable,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class PaginatedProductsModel {
  final List<ProductModel> products;
  final int page;
  final int totalPages;
  final int total;

  const PaginatedProductsModel({
    required this.products,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  factory PaginatedProductsModel.fromJson(Map<String, dynamic> json) {
    final data = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();

    final pagination = json['pagination'] as Map<String, dynamic>? ?? const {};

    return PaginatedProductsModel(
      products: data,
      page: (pagination['page'] as num?)?.toInt() ?? 1,
      totalPages: (pagination['totalPages'] as num?)?.toInt() ?? 1,
      total: (pagination['total'] as num?)?.toInt() ?? data.length,
    );
  }
}
