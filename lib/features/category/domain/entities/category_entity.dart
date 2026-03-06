class CategoryEntity {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final String? parentId;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.parentId,
  });
}
