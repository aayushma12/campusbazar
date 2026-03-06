import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product_filter_entity.dart';
import '../../domain/usecases/apply_filter_usecase.dart';
import '../../domain/usecases/clear_filter_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import 'product_filter_state.dart';
import 'products_providers.dart';

final searchProductsUseCaseProvider = Provider<SearchProductsUseCase>((ref) {
  return SearchProductsUseCase(ref.read(productsRepositoryProvider));
});

final applyFilterUseCaseProvider = Provider<ApplyFilterUseCase>((ref) {
  return ApplyFilterUseCase(ref.read(productsRepositoryProvider));
});

final clearFilterUseCaseProvider = Provider<ClearFilterUseCase>((ref) {
  return ClearFilterUseCase();
});

final productFilterNotifierProvider = NotifierProvider<ProductFilterNotifier, ProductFilterState>(
  ProductFilterNotifier.new,
);

class ProductFilterNotifier extends Notifier<ProductFilterState> {
  @override
  ProductFilterState build() {
    final filter = ref.read(clearFilterUseCaseProvider).call(limit: 12);
    return ProductFilterState(filter: filter);
  }

  Future<void> loadInitial() async {
    final resetPage = state.filter.copyWith(page: 1);
    state = state.copyWith(
      status: ProductFilterStatus.loading,
      filter: resetPage,
      clearError: true,
      unauthorized: false,
      isFetchingMore: false,
      hasMore: true,
    );

    final result = await ref.read(searchProductsUseCaseProvider).call(resetPage);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProductFilterStatus.error,
          errorMessage: failure.message,
          unauthorized: _isUnauthorized(failure.message),
        );
      },
      (products) {
        state = state.copyWith(
          status: products.isEmpty ? ProductFilterStatus.empty : ProductFilterStatus.loaded,
          products: products,
          hasMore: products.length >= resetPage.limit,
          clearError: true,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isFetchingMore || !state.hasMore) return;

    final nextFilter = state.filter.copyWith(page: state.filter.page + 1);
    state = state.copyWith(isFetchingMore: true, clearError: true);

    final result = await ref.read(applyFilterUseCaseProvider).call(nextFilter);
    result.fold(
      (failure) {
        state = state.copyWith(
          isFetchingMore: false,
          status: ProductFilterStatus.error,
          errorMessage: failure.message,
          unauthorized: _isUnauthorized(failure.message),
        );
      },
      (products) {
        state = state.copyWith(
          status: ProductFilterStatus.loaded,
          isFetchingMore: false,
          filter: nextFilter,
          products: [...state.products, ...products],
          hasMore: products.length >= nextFilter.limit,
        );
      },
    );
  }

  Future<void> searchByKeyword(String keyword) async {
    final next = state.filter.copyWith(
      keyword: keyword.trim(),
      page: 1,
      clearKeyword: keyword.trim().isEmpty,
    );
    await _apply(next);
  }

  Future<void> applyFilter({
    String? campus,
    String? condition,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? sortBy,
  }) async {
    final next = state.filter.copyWith(
      campus: campus,
      condition: condition,
      minPrice: minPrice,
      maxPrice: maxPrice,
      category: category,
      sortBy: sortBy,
      clearCampus: campus == null || campus.trim().isEmpty,
      clearCondition: condition == null || condition.trim().isEmpty,
      clearMinPrice: minPrice == null,
      clearMaxPrice: maxPrice == null,
      clearCategory: category == null || category.trim().isEmpty,
      clearSortBy: sortBy == null || sortBy.trim().isEmpty,
      page: 1,
    );
    await _apply(next);
  }

  Future<void> clearAll() async {
    final cleared = ref.read(clearFilterUseCaseProvider).call(limit: state.filter.limit);
    await _apply(cleared);
  }

  Future<void> removeSingleFilter(String key) async {
    ProductFilter next = state.filter;
    switch (key) {
      case 'keyword':
        next = next.copyWith(clearKeyword: true, page: 1);
        break;
      case 'campus':
        next = next.copyWith(clearCampus: true, page: 1);
        break;
      case 'condition':
        next = next.copyWith(clearCondition: true, page: 1);
        break;
      case 'minPrice':
        next = next.copyWith(clearMinPrice: true, page: 1);
        break;
      case 'maxPrice':
        next = next.copyWith(clearMaxPrice: true, page: 1);
        break;
      case 'category':
        next = next.copyWith(clearCategory: true, page: 1);
        break;
      case 'sortBy':
        next = next.copyWith(clearSortBy: true, page: 1);
        break;
      default:
        return;
    }

    await _apply(next);
  }

  Future<void> refresh() => loadInitial();

  Future<void> _apply(ProductFilter filter) async {
    state = state.copyWith(
      status: ProductFilterStatus.loading,
      filter: filter,
      clearError: true,
      unauthorized: false,
      hasMore: true,
      isFetchingMore: false,
    );

    final result = await ref.read(applyFilterUseCaseProvider).call(filter);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProductFilterStatus.error,
          errorMessage: failure.message,
          unauthorized: _isUnauthorized(failure.message),
        );
      },
      (products) {
        state = state.copyWith(
          status: products.isEmpty ? ProductFilterStatus.empty : ProductFilterStatus.loaded,
          products: products,
          hasMore: products.length >= filter.limit,
          clearError: true,
        );
      },
    );
  }

  bool _isUnauthorized(String message) {
    final m = message.toLowerCase();
    return m.contains('401') || m.contains('unauthorized');
  }
}
