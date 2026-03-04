class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final bool negotiable;
  final String condition;
  final String categoryId;
  final String campus;
  final List<String> images;
  final String status;
  final String ownerId;
  final int views;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.negotiable,
    required this.condition,
    required this.categoryId,
    required this.campus,
    required this.images,
    required this.status,
    required this.ownerId,
    required this.views,
    required this.createdAt,
  });
}
