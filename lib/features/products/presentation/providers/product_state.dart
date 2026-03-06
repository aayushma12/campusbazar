import '../../domain/entities/product_entity.dart';

enum ProductStatusState {
  initial,
  loading,
  loaded,
  creating,
  updating,
  deleting,
  success,
  error,
}

class ProductState {
  final ProductStatusState status;
  final List<ProductEntity> products;
  final ProductEntity? selectedProduct;
  final String? errorMessage;
  final String? successMessage;
  final bool unauthorized;
  final bool isOwner;

  final int page;
  final int totalPages;
  final bool isFetchingMore;

  const ProductState({
    this.status = ProductStatusState.initial,
    this.products = const [],
    this.selectedProduct,
    this.errorMessage,
    this.successMessage,
    this.unauthorized = false,
    this.isOwner = false,
    this.page = 1,
    this.totalPages = 1,
    this.isFetchingMore = false,
  });

  bool get hasMore => page < totalPages;

  ProductState copyWith({
    ProductStatusState? status,
    List<ProductEntity>? products,
    ProductEntity? selectedProduct,
    String? errorMessage,
    String? successMessage,
    bool? unauthorized,
    bool? isOwner,
    int? page,
    int? totalPages,
    bool? isFetchingMore,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelected = false,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      selectedProduct: clearSelected ? null : (selectedProduct ?? this.selectedProduct),
      errorMessage: clearError ? null : errorMessage,
      successMessage: clearSuccess ? null : successMessage,
      unauthorized: unauthorized ?? this.unauthorized,
      isOwner: isOwner ?? this.isOwner,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
    );
  }
}
