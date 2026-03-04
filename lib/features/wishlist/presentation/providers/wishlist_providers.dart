import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/api/api_client.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../data/datasources/wishlist_remote_data_source.dart';
import '../../data/models/wishlist_model.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../domain/usecases/add_to_wishlist_usecase.dart';
import '../../domain/usecases/check_wishlist_status_usecase.dart';
import '../../domain/usecases/get_wishlist_usecase.dart';
import '../../domain/usecases/remove_from_wishlist_usecase.dart';
import 'wishlist_state.dart';

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepositoryImpl(
    remote: WishlistRemoteDataSourceImpl(apiClient: GetIt.instance<ApiClient>()),
  );
});

final getWishlistUseCaseProvider = Provider<GetWishlistUseCase>((ref) {
  return GetWishlistUseCase(ref.read(wishlistRepositoryProvider));
});

final addToWishlistUseCaseProvider = Provider<AddToWishlistUseCase>((ref) {
  return AddToWishlistUseCase(ref.read(wishlistRepositoryProvider));
});

final removeFromWishlistUseCaseProvider = Provider<RemoveFromWishlistUseCase>((ref) {
  return RemoveFromWishlistUseCase(ref.read(wishlistRepositoryProvider));
});

final checkWishlistStatusUseCaseProvider = Provider<CheckWishlistStatusUseCase>((ref) {
  return CheckWishlistStatusUseCase(ref.read(wishlistRepositoryProvider));
});

final wishlistNotifierProvider = NotifierProvider<WishlistNotifier, WishlistState>(WishlistNotifier.new);

class MoveToCartResult {
  final bool success;
  final bool quantityUpdated;
  final String? message;

  const MoveToCartResult({
    required this.success,
    this.quantityUpdated = false,
    this.message,
  });
}

class WishlistAddToCartResult {
  final bool success;
  final bool quantityUpdated;
  final String? message;

  const WishlistAddToCartResult({
    required this.success,
    this.quantityUpdated = false,
    this.message,
  });
}

class WishlistNotifier extends Notifier<WishlistState> {
  @override
  WishlistState build() => const WishlistState();

  Future<void> loadWishlist() async {
    state = state.copyWith(status: WishlistStatus.loading, clearError: true, unauthorized: false);

    final result = await ref.read(getWishlistUseCaseProvider).call();
    result.fold(
      (failure) {
        state = state.copyWith(
          status: WishlistStatus.error,
          errorMessage: failure.message,
          unauthorized: _isUnauthorized(failure.message),
        );
      },
      (items) {
        state = state.copyWith(status: WishlistStatus.loaded, items: items, clearError: true, unauthorized: false);
      },
    );
  }

  /// Optimistic toggle:
  /// - instantly updates local UI
  /// - calls API
  /// - rollback on failure
  Future<void> toggleWishlistOptimistic(ProductEntity product) async {
    final productId = product.id;
    if (state.isUpdating(productId)) return;

    final previousItems = List<WishlistItem>.from(state.items);
    final currentlyInWishlist = state.isInWishlist(productId);

    final optimisticItems = currentlyInWishlist
        ? state.items.where((e) => e.productId != productId).toList()
        : [
            WishlistModel.optimistic(
              productId: product.id,
              title: product.title,
              price: product.price,
              image: product.images.isNotEmpty ? product.images.first : '',
            ),
            ...state.items,
          ];

    final updatingSet = {...state.updatingProductIds, productId};

    state = state.copyWith(
      status: WishlistStatus.updating,
      items: optimisticItems,
      updatingProductIds: updatingSet,
      clearError: true,
      unauthorized: false,
    );

    final result = currentlyInWishlist
        ? await ref.read(removeFromWishlistUseCaseProvider).call(productId)
        : await ref.read(addToWishlistUseCaseProvider).call(productId);

    result.fold(
      (failure) {
        final rollbackSet = {...state.updatingProductIds}..remove(productId);
        state = state.copyWith(
          status: WishlistStatus.error,
          items: previousItems,
          errorMessage: failure.message,
          unauthorized: _isUnauthorized(failure.message),
          updatingProductIds: rollbackSet,
        );
      },
      (_) {
        final doneSet = {...state.updatingProductIds}..remove(productId);
        state = state.copyWith(
          status: WishlistStatus.loaded,
          updatingProductIds: doneSet,
          clearError: true,
          unauthorized: false,
        );
      },
    );
  }

  Future<void> removeByProductIdOptimistic(String productId) async {
    if (state.isUpdating(productId)) return;

    final previousItems = List<WishlistItem>.from(state.items);
    final updatingSet = {...state.updatingProductIds, productId};

    state = state.copyWith(
      status: WishlistStatus.updating,
      items: state.items.where((e) => e.productId != productId).toList(),
      updatingProductIds: updatingSet,
      clearError: true,
    );

    final result = await ref.read(removeFromWishlistUseCaseProvider).call(productId);

    result.fold(
      (failure) {
        final rollbackSet = {...state.updatingProductIds}..remove(productId);
        state = state.copyWith(
          status: WishlistStatus.error,
          items: previousItems,
          errorMessage: failure.message,
          unauthorized: _isUnauthorized(failure.message),
          updatingProductIds: rollbackSet,
        );
      },
      (_) {
        final doneSet = {...state.updatingProductIds}..remove(productId);
        state = state.copyWith(
          status: WishlistStatus.loaded,
          updatingProductIds: doneSet,
          clearError: true,
          unauthorized: false,
        );
      },
    );
  }

  Future<WishlistAddToCartResult> addToCartFromWishlist(String productId, {int quantity = 1}) async {
    if (quantity < 1 || state.isUpdating(productId)) {
      return const WishlistAddToCartResult(success: false, message: 'Unable to process item right now.');
    }

    final exists = state.items.any((e) => e.productId == productId);
    if (!exists) {
      return const WishlistAddToCartResult(success: false, message: 'Wishlist item not found.');
    }

    final updatingSet = {...state.updatingProductIds, productId};
    state = state.copyWith(
      status: WishlistStatus.updating,
      updatingProductIds: updatingSet,
      clearError: true,
      unauthorized: false,
    );

    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final cartOutcome = await cartNotifier.addOrIncrement(productId, quantity: quantity);

    final doneSet = {...state.updatingProductIds}..remove(productId);

    if (cartOutcome == CartAddOutcome.failed) {
      final cartError = ref.read(cartNotifierProvider).errorMessage;
      state = state.copyWith(
        status: WishlistStatus.error,
        updatingProductIds: doneSet,
        errorMessage: cartError ?? 'Failed to add to cart.',
        unauthorized: _isUnauthorized(cartError ?? ''),
      );
      return WishlistAddToCartResult(success: false, message: cartError ?? 'Failed to add to cart.');
    }

    state = state.copyWith(
      status: WishlistStatus.loaded,
      updatingProductIds: doneSet,
      clearError: true,
      unauthorized: false,
    );

    return WishlistAddToCartResult(
      success: true,
      quantityUpdated: cartOutcome == CartAddOutcome.quantityUpdated,
      message: cartOutcome == CartAddOutcome.quantityUpdated ? 'Cart quantity updated.' : 'Added to cart.',
    );
  }

  Future<MoveToCartResult> moveToCartAndRemoveFromWishlist(String productId, {int quantity = 1}) async {
    if (quantity < 1 || state.isUpdating(productId)) {
      return const MoveToCartResult(success: false, message: 'Unable to process item right now.');
    }

    final wishlistItem = state.items.where((e) => e.productId == productId).cast<WishlistItem?>().firstWhere(
      (e) => e != null,
      orElse: () => null,
    );

    if (wishlistItem == null) {
      return const MoveToCartResult(success: false, message: 'Wishlist item not found.');
    }

    final previousItems = List<WishlistItem>.from(state.items);
    final updatingSet = {...state.updatingProductIds, productId};

    state = state.copyWith(
      status: WishlistStatus.updating,
      items: state.items.where((e) => e.productId != productId).toList(),
      updatingProductIds: updatingSet,
      clearError: true,
      unauthorized: false,
    );

    final cartNotifier = ref.read(cartNotifierProvider.notifier);
    final cartOutcome = await cartNotifier.addOrIncrement(productId, quantity: quantity);

    if (cartOutcome == CartAddOutcome.failed) {
      final rollbackSet = {...state.updatingProductIds}..remove(productId);
      final cartError = ref.read(cartNotifierProvider).errorMessage;
      state = state.copyWith(
        status: WishlistStatus.error,
        items: previousItems,
        updatingProductIds: rollbackSet,
        errorMessage: cartError ?? 'Failed to add to cart.',
        unauthorized: _isUnauthorized(cartError ?? ''),
      );
      return MoveToCartResult(success: false, message: cartError ?? 'Failed to add to cart.');
    }

    final removeResult = await ref.read(removeFromWishlistUseCaseProvider).call(productId);
    return await removeResult.fold(
      (failure) async {
        await _rollbackCartChangeAfterFailedWishlistDelete(
          productId: productId,
          quantity: quantity,
          cartOutcome: cartOutcome,
        );

        final rollbackSet = {...state.updatingProductIds}..remove(productId);
        state = state.copyWith(
          status: WishlistStatus.error,
          items: previousItems,
          updatingProductIds: rollbackSet,
          errorMessage: failure.message,
          unauthorized: _isUnauthorized(failure.message),
        );

        final rollbackError = ref.read(cartNotifierProvider).errorMessage;
        final message = rollbackError == null || rollbackError.isEmpty
            ? failure.message
            : '${failure.message}. Cart rollback issue: $rollbackError';

        return MoveToCartResult(success: false, message: message);
      },
      (_) async {
        final doneSet = {...state.updatingProductIds}..remove(productId);
        state = state.copyWith(
          status: WishlistStatus.loaded,
          updatingProductIds: doneSet,
          clearError: true,
          unauthorized: false,
        );

        return MoveToCartResult(
          success: true,
          quantityUpdated: cartOutcome == CartAddOutcome.quantityUpdated,
          message: cartOutcome == CartAddOutcome.quantityUpdated
              ? 'Cart quantity updated and removed from wishlist.'
              : 'Added to cart and removed from wishlist.',
        );
      },
    );
  }

  Future<void> _rollbackCartChangeAfterFailedWishlistDelete({
    required String productId,
    required int quantity,
    required CartAddOutcome cartOutcome,
  }) async {
    final cartNotifier = ref.read(cartNotifierProvider.notifier);

    if (cartOutcome == CartAddOutcome.added) {
      await cartNotifier.removeItem(productId);
      return;
    }

    if (cartOutcome == CartAddOutcome.quantityUpdated) {
      final cartState = ref.read(cartNotifierProvider);
      CartItem? cartItem;
      for (final item in cartState.items) {
        if (item.productId == productId) {
          cartItem = item;
          break;
        }
      }

      if (cartItem == null) {
        return;
      }

      final revertedQuantity = cartItem.quantity - quantity;
      if (revertedQuantity < 1) {
        await cartNotifier.removeItem(productId);
      } else {
        await cartNotifier.updateQuantity(productId, revertedQuantity);
      }
    }
  }

  Future<bool> isInWishlist(String productId) async {
    if (state.items.isNotEmpty) {
      return state.isInWishlist(productId);
    }
    final result = await ref.read(checkWishlistStatusUseCaseProvider).call(productId);
    return result.fold((_) => false, (status) => status);
  }

  void clearError() {
    state = state.copyWith(clearError: true, unauthorized: false);
  }

  bool _isUnauthorized(String message) {
    final lower = message.toLowerCase();
    return lower.contains('unauthorized') || lower.contains('401');
  }
}
