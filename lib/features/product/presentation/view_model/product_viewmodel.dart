import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/fetch_products_usecase.dart';
import '../../domain/usecases/get_product_usecase.dart';
import '../../domain/usecases/product_crud_usecases.dart';
import '../state/product_state.dart';
import '../../../../core/services/service_locator.dart';

final productViewModelProvider = NotifierProvider<ProductViewModel, ProductState>(
  ProductViewModel.new,
);

final productDetailProvider = FutureProvider.autoDispose.family<Product, String>((ref, productId) async {
  final id = productId.trim();
  if (id.isEmpty || id.toLowerCase() == 'null') {
    throw Exception('Invalid product ID');
  }

  final useCase = sl<GetProductUseCase>();
  return useCase(id);
});

class ProductViewModel extends Notifier<ProductState> {
  late final FetchProductsUseCase _fetchUseCase;
  late final GetProductUseCase _getUseCase;
  late final CreateProductUseCase _createUseCase;
  late final UpdateProductUseCase _updateUseCase;
  late final DeleteProductUseCase _deleteUseCase;
  late final ToggleFavoriteUseCase _toggleFavUseCase;
  late final FetchFavoritesUseCase _fetchFavUseCase;

  @override
  ProductState build() {
    _fetchUseCase = sl<FetchProductsUseCase>();
    _getUseCase = sl<GetProductUseCase>();
    _createUseCase = sl<CreateProductUseCase>();
    _updateUseCase = sl<UpdateProductUseCase>();
    _deleteUseCase = sl<DeleteProductUseCase>();
    _toggleFavUseCase = sl<ToggleFavoriteUseCase>();
    _fetchFavUseCase = sl<FetchFavoritesUseCase>();

    return const ProductState();
  }

  Future<void> fetchProducts({FetchProductsParams? params}) async {
    state = state.copyWith(status: ProductStatus.loading, isLoading: true);
    try {
      final list = await _fetchUseCase(params ?? FetchProductsParams());
      state = state.copyWith(status: ProductStatus.success, products: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(status: ProductStatus.error, errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> getProduct(String id) async {
    state = state.copyWith(
      status: ProductStatus.loading,
      isLoading: true,
      clearSelected: true,
      clearError: true,
    );
    try {
      final product = await _getUseCase(id);
      state = state.copyWith(status: ProductStatus.success, selectedProduct: product, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        status: ProductStatus.error,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> createProduct(Product product) async {
    state = state.copyWith(isLoading: true);
    try {
      final created = await _createUseCase(product);
      // Optionally add to products list
      final updatedList = [...?state.products, created];
      state = state.copyWith(products: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> updateProduct(Product product) async {
    state = state.copyWith(isLoading: true);
    try {
      final updated = await _updateUseCase(product);
      final updatedList = state.products?.map((p) => p.id == updated.id ? updated : p).toList();
      state = state.copyWith(products: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> deleteProduct(String id) async {
    state = state.copyWith(isLoading: true);
    try {
      await _deleteUseCase(id);
      final updatedList = state.products?.where((p) => p.id != id).toList();
      state = state.copyWith(products: updatedList, isLoading: false);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      await _toggleFavUseCase(id);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> fetchFavorites() async {
    state = state.copyWith(status: ProductStatus.loading, isLoading: true);
    try {
      final favs = await _fetchFavUseCase();
      state = state.copyWith(status: ProductStatus.success, products: favs, isLoading: false);
    } catch (e) {
      state = state.copyWith(status: ProductStatus.error, errorMessage: e.toString(), isLoading: false);
    }
  }
}
