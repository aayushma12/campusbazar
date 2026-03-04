import '../../domain/entities/category_entity.dart';

enum CategoryStatus { initial, loading, success, error }

class CategoryState {
  final CategoryStatus status;
  final List<CategoryEntity> categories;
  final String? errorMessage;
  final bool isLoading;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.errorMessage,
    this.isLoading = false,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<CategoryEntity>? categories,
    String? errorMessage,
    bool? isLoading,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
