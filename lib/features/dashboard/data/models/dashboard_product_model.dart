import '../../domain/entities/dashboard_product_entity.dart';

class DashboardProductModel extends DashboardProduct {
  const DashboardProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.categoryId,
    required super.condition,
    required super.campus,
    required super.negotiable,
    required super.images,
    required super.status,
    required super.createdAt,
  });

  factory DashboardProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['categoryId'];
    final categoryId = category is Map<String, dynamic>
        ? (category['_id'] ?? category['id'] ?? '').toString()
        : (category ?? '').toString();

    return DashboardProductModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      categoryId: categoryId,
      condition: (json['condition'] ?? '').toString(),
      campus: (json['campus'] ?? '').toString(),
      negotiable: (json['negotiable'] ?? false) as bool,
      images: (json['images'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      status: (json['status'] ?? 'available').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  factory DashboardProductModel.fromMap(Map<dynamic, dynamic> map) {
    return DashboardProductModel(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0,
      categoryId: (map['categoryId'] ?? '').toString(),
      condition: (map['condition'] ?? '').toString(),
      campus: (map['campus'] ?? '').toString(),
      negotiable: (map['negotiable'] ?? false) as bool,
      images: (map['images'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      status: (map['status'] ?? 'available').toString(),
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
      'condition': condition,
      'campus': campus,
      'negotiable': negotiable,
      'images': images,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
