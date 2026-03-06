import 'package:equatable/equatable.dart';

/// Domain entity representing a product shown on the dashboard.
class DashboardProduct extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final String categoryId;
  final String condition;
  final String campus;
  final bool negotiable;
  final List<String> images;
  final String status;
  final DateTime createdAt;

  const DashboardProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.condition,
    required this.campus,
    required this.negotiable,
    required this.images,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        price,
        categoryId,
        condition,
        campus,
        negotiable,
        images,
        status,
        createdAt,
      ];
}
