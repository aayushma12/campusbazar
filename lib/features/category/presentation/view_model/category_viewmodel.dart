import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../state/category_state.dart';
import '../../../../core/services/service_locator.dart';

final categoryViewModelProvider = NotifierProvider<CategoryViewModel, CategoryState>(
  CategoryViewModel.new,
);

class CategoryViewModel extends Notifier<CategoryState> {
  late final CategoryRepository _repository;

  @override
  CategoryState build() {
    _repository = sl<CategoryRepository>();
    return const CategoryState();
  }

  Future<void> loadCategories() async {
    state = state.copyWith(status: CategoryStatus.loading, isLoading: true);
    try {
      final data = await _repository.getCategories();
      state = state.copyWith(status: CategoryStatus.success, categories: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(status: CategoryStatus.error, errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<CategoryEntity?> createCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return null;

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final created = await _repository.createCategory(trimmed);

      final list = List<CategoryEntity>.from(state.categories);
      final existingIndex = list.indexWhere((c) => c.id == created.id);
      if (existingIndex >= 0) {
        list[existingIndex] = created;
      } else {
        list.add(created);
      }

      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      state = state.copyWith(
        status: CategoryStatus.success,
        categories: list,
        isLoading: false,
      );
      return created;
    } catch (e) {
      state = state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
      return null;
    }
  }
}
