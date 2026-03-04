import '../../domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  CategoryModel({
    required String id,
    required String name,
    required String slug,
    required String? description,
    required String? parentId,
  }) : super(
          id: id,
          name: name,
          slug: slug,
          description: description,
          parentId: parentId,
        );

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString(),
      parentId: json['parentId']?.toString(),
    );
  }
}
