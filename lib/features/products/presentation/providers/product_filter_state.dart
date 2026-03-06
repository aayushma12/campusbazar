import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_filter_entity.dart';

enum ProductFilterStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

class ProductFilterState {
  final ProductFilterStatus status;
  final ProductFilter filter;
  final List<ProductEntity> products;
  final String? errorMessage;
  final bool unauthorized;
  final bool isFetchingMore;
  final bool hasMore;

  const ProductFilterState({
    this.status = ProductFilterStatus.initial,
    this.filter = const ProductFilter(),
    this.products = const [],
    this.errorMessage,
    this.unauthorized = false,
    this.isFetchingMore = false,
    this.hasMore = true,
  });

  int get activeFilterCount => filter.activeFilterCount;

  ProductFilterState copyWith({
    ProductFilterStatus? status,
    ProductFilter? filter,
    List<ProductEntity>? products,
    String? errorMessage,
    bool? unauthorized,
    bool? isFetchingMore,
    bool? hasMore,
    bool clearError = false,
  }) {
    return ProductFilterState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      products: products ?? this.products,
      errorMessage: clearError ? null : errorMessage,
      unauthorized: unauthorized ?? this.unauthorized,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
