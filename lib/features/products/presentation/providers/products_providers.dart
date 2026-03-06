import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/datasources/products_local_data_source.dart';
import '../../data/datasources/products_remote_data_source.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/repositories/products_repository.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import 'product_state.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(
    remote: ProductsRemoteDataSourceImpl(apiClient: GetIt.instance<ApiClient>()),
    local: ProductsLocalDataSourceImpl(),
    networkInfo: NetworkInfoImpl(),
  );
});

final getProductsUseCaseProvider = Provider<GetProductsUseCase>((ref) {
  return GetProductsUseCase(ref.read(productsRepositoryProvider));
});

final getProductDetailUseCaseProvider = Provider<GetProductDetailUseCase>((ref) {
  return GetProductDetailUseCase(ref.read(productsRepositoryProvider));
});

final createProductUseCaseProvider = Provider<CreateProductUseCase>((ref) {
  return CreateProductUseCase(ref.read(productsRepositoryProvider));
});

final updateProductUseCaseProvider = Provider<UpdateProductUseCase>((ref) {
  return UpdateProductUseCase(ref.read(productsRepositoryProvider));
});

final deleteProductUseCaseProvider = Provider<DeleteProductUseCase>((ref) {
  return DeleteProductUseCase(ref.read(productsRepositoryProvider));
});

final productsNotifierProvider = NotifierProvider<ProductsNotifier, ProductState>(ProductsNotifier.new);

class ProductsNotifier extends Notifier<ProductState> {
  static const _limit = 12;

  @override
  ProductState build() => const ProductState();

  Future<void> loadInitial() async {
    state = state.copyWith(
      status: ProductStatusState.loading,
      clearError: true,
      clearSuccess: true,
      unauthorized: false,
      page: 1,
      totalPages: 1,
    );

    final result = await ref.read(getProductsUseCaseProvider).call(page: 1, limit: _limit);
    result.fold(
      (failure) => state = state.copyWith(
        status: ProductStatusState.error,
        errorMessage: failure.message,
        unauthorized: _isUnauthorized(failure.message),
      ),
      (data) => state = state.copyWith(
        status: ProductStatusState.loaded,
        products: data.products,
        page: data.currentPage,
        totalPages: data.totalPages,
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.isFetchingMore || !state.hasMore) return;

    state = state.copyWith(isFetchingMore: true, clearError: true);
    final nextPage = state.page + 1;

    final result = await ref.read(getProductsUseCaseProvider).call(page: nextPage, limit: _limit);
    result.fold(
      (failure) => state = state.copyWith(
        isFetchingMore: false,
        status: ProductStatusState.error,
        errorMessage: failure.message,
        unauthorized: _isUnauthorized(failure.message),
      ),
      (data) => state = state.copyWith(
        status: ProductStatusState.loaded,
        isFetchingMore: false,
        products: [...state.products, ...data.products],
        page: data.currentPage,
        totalPages: data.totalPages,
      ),
    );
  }

  Future<void> refresh() => loadInitial();

  Future<void> getDetail(String id) async {
    state = state.copyWith(
      status: ProductStatusState.loading,
      clearError: true,
      clearSuccess: true,
      clearSelected: true,
    );

    final result = await ref.read(getProductDetailUseCaseProvider).call(id);
    result.fold(
      (failure) => state = state.copyWith(
        status: ProductStatusState.error,
        errorMessage: failure.message,
        unauthorized: _isUnauthorized(failure.message),
      ),
      (product) async {
        final currentUserId = await _getCurrentUserId();
        state = state.copyWith(
          status: ProductStatusState.loaded,
          selectedProduct: product,
          isOwner: currentUserId != null && currentUserId == product.sellerId,
        );
      },
    );
  }

  Future<bool> createProduct({
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String condition,
    required String campus,
    required bool negotiable,
    required List<File> images,
  }) async {
    state = state.copyWith(status: ProductStatusState.creating, clearError: true, clearSuccess: true);

    final result = await ref.read(createProductUseCaseProvider).call(
          title: title,
          description: description,
          price: price,
          categoryId: categoryId,
          condition: condition,
          campus: campus,
          negotiable: negotiable,
          images: images,
        );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ProductStatusState.error,
          errorMessage: failure.message,
          unauthorized: _isUnauthorized(failure.message),
        );
        return false;
      },
      (created) {
        state = state.copyWith(
          status: ProductStatusState.success,
          successMessage: 'Product created successfully',
          products: [created, ...state.products],
        );
        return true;
      },
    );
  }

  Future<bool> updateProduct({
    required String id,
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String condition,
    required String campus,
    required bool negotiable,
  }) async {
    state = state.copyWith(status: ProductStatusState.updating, clearError: true, clearSuccess: true);

    final result = await ref.read(updateProductUseCaseProvider).call(
          id: id,
          title: title,
          description: description,
          price: price,
          categoryId: categoryId,
          condition: condition,
          campus: campus,
          negotiable: negotiable,
        );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ProductStatusState.error,
          errorMessage: failure.message,
          unauthorized: _isUnauthorized(failure.message),
        );
        return false;
      },
      (updated) {
        final updatedList = state.products.map((p) => p.id == updated.id ? updated : p).toList();
        state = state.copyWith(
          status: ProductStatusState.success,
          successMessage: 'Product updated successfully',
          products: updatedList,
          selectedProduct: updated,
        );
        return true;
      },
    );
  }

  Future<bool> deleteProduct(String productId) async {
    state = state.copyWith(status: ProductStatusState.deleting, clearError: true, clearSuccess: true);
    final result = await ref.read(deleteProductUseCaseProvider).call(productId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ProductStatusState.error,
          errorMessage: failure.message,
          unauthorized: _isUnauthorized(failure.message),
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          status: ProductStatusState.success,
          successMessage: 'Product deleted',
          products: state.products.where((p) => p.id != productId).toList(),
          clearSelected: true,
        );
        return true;
      },
    );
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true, unauthorized: false);
  }

  bool _isUnauthorized(String message) {
    final m = message.toLowerCase();
    return m.contains('401') || m.contains('unauthorized');
  }

  Future<String?> _getCurrentUserId() async {
    try {
      if (Hive.isBoxOpen('authenticationBox')) {
        final box = Hive.box('authenticationBox');
        final user = box.get('AUTH_USER');
        if (user != null) {
          final id = (user as dynamic).id?.toString();
          if (id != null && id.isNotEmpty) return id;
        }
      }
    } catch (_) {}

    try {
      if (Hive.isBoxOpen('authBox')) {
        final box = Hive.box('authBox');
        final user = box.get('CACHED_USER');
        if (user != null) {
          final id = (user as dynamic).id?.toString();
          if (id != null && id.isNotEmpty) return id;
        }
      }
    } catch (_) {}

    return null;
  }
}
