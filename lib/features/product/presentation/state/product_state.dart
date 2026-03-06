import '../../domain/entities/product_entity.dart';

enum ProductStatus { initial, loading, success, error }

class ProductState {
  final ProductStatus status;
  final List<Product>? products;
  final Product? selectedProduct;
  final String? errorMessage;
  final bool isLoading;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products,
    this.selectedProduct,
    this.errorMessage,
    this.isLoading = false,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    Product? selectedProduct,
    String? errorMessage,
    bool? isLoading,
    bool clearSelected = false,
    bool clearError = false,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      selectedProduct: clearSelected ? null : (selectedProduct ?? this.selectedProduct),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
