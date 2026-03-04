import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../../../core/api/api_client.dart';
import '../../data/datasources/cart_remote_data_source.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_summary_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/get_cart_items_usecase.dart';
import '../../domain/usecases/get_cart_summary_usecase.dart';
import '../../domain/usecases/remove_cart_item_usecase.dart';
import '../../domain/usecases/update_cart_quantity_usecase.dart';
import 'cart_state.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(CartRemoteDataSourceImpl(GetIt.instance<ApiClient>()));
});

final getCartItemsUseCaseProvider = Provider<GetCartItemsUseCase>((ref) {
  return GetCartItemsUseCase(ref.read(cartRepositoryProvider));
});

final addToCartUseCaseProvider = Provider<AddToCartUseCase>((ref) {
  return AddToCartUseCase(ref.read(cartRepositoryProvider));
});

final updateCartQuantityUseCaseProvider = Provider<UpdateCartQuantityUseCase>((ref) {
  return UpdateCartQuantityUseCase(ref.read(cartRepositoryProvider));
});

final removeCartItemUseCaseProvider = Provider<RemoveCartItemUseCase>((ref) {
  return RemoveCartItemUseCase(ref.read(cartRepositoryProvider));
});

final clearCartUseCaseProvider = Provider<ClearCartUseCase>((ref) {
  return ClearCartUseCase(ref.read(cartRepositoryProvider));
});

final getCartSummaryUseCaseProvider = Provider<GetCartSummaryUseCase>((ref) {
  return GetCartSummaryUseCase(ref.read(cartRepositoryProvider));
});

final cartNotifierProvider = NotifierProvider<CartNotifier, CartState>(CartNotifier.new);

// Backward-compatible alias for old imports.
final cartViewModelProvider = cartNotifierProvider;

enum CartAddOutcome {
  added,
  quantityUpdated,
  failed,
}

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  Future<void> loadCart() async {
    state = state.copyWith(status: CartStatus.loading, clearError: true, unauthorized: false);
    try {
      final items = await ref.read(getCartItemsUseCaseProvider).call();
      final summary = _calculateSummary(items);
      state = state.copyWith(
        status: CartStatus.loaded,
        items: items,
        summary: summary,
        clearError: true,
        unauthorized: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: CartStatus.error,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
    }
  }

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    if (quantity < 1) return;

    state = state.copyWith(status: CartStatus.updating, clearError: true, clearSuccess: true);
    try {
      await ref.read(addToCartUseCaseProvider).call(productId, quantity);
      await loadCart();
      state = state.copyWith(successMessage: 'Added to cart');
    } catch (e) {
      final message = _msg(e);

      if (_looksLikeDuplicateKey(message)) {
        try {
          await loadCart();
          CartItem? existing;
          for (final item in state.items) {
            if (item.productId == productId) {
              existing = item;
              break;
            }
          }

          if (existing != null) {
            await ref.read(updateCartQuantityUseCaseProvider).call(productId, existing.quantity + quantity);
            await loadCart();
            state = state.copyWith(
              status: CartStatus.loaded,
              successMessage: 'Cart quantity updated',
              clearError: true,
              unauthorized: false,
            );
            return;
          }
        } catch (inner) {
          state = state.copyWith(
            status: CartStatus.error,
            errorMessage: _msg(inner),
            unauthorized: _isUnauthorized(inner),
          );
          return;
        }
      }

      state = state.copyWith(
        status: CartStatus.error,
        errorMessage: message,
        unauthorized: _isUnauthorized(e),
      );
    }
  }

  Future<CartAddOutcome> addOrIncrement(String productId, {int quantity = 1}) async {
    if (quantity < 1) return CartAddOutcome.failed;

    var canUseLocalCartSnapshot = true;
    if (state.status == CartStatus.initial) {
      await loadCart();
      if (state.status == CartStatus.error) {
        // Do not fail early. Try direct add anyway so transient cart-read
        // failures do not block add-to-cart from product detail.
        canUseLocalCartSnapshot = false;
      }
    }

    CartItem? existing;
    if (canUseLocalCartSnapshot) {
      for (final item in state.items) {
        if (item.productId == productId) {
          existing = item;
          break;
        }
      }
    }

    if (existing == null) {
      await addToCart(productId, quantity: quantity);
      return state.status == CartStatus.error ? CartAddOutcome.failed : CartAddOutcome.added;
    }

    await updateQuantity(productId, existing.quantity + quantity);
    if (state.status == CartStatus.error) {
      return CartAddOutcome.failed;
    }

    state = state.copyWith(successMessage: 'Cart quantity updated');
    return CartAddOutcome.quantityUpdated;
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity < 1 || state.isUpdating(productId)) return;

    final previousItems = List<CartItem>.from(state.items);
    final optimisticItems = state.items
        .map((e) => e.productId == productId ? e.copyWith(quantity: quantity) : e)
        .toList();
    final updatingIds = {...state.updatingProductIds, productId};

    state = state.copyWith(
      status: CartStatus.updating,
      items: optimisticItems,
      summary: _calculateSummary(optimisticItems),
      updatingProductIds: updatingIds,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await ref.read(updateCartQuantityUseCaseProvider).call(productId, quantity);
      final doneIds = {...state.updatingProductIds}..remove(productId);
      state = state.copyWith(
        status: CartStatus.loaded,
        updatingProductIds: doneIds,
        clearError: true,
      );
    } catch (e) {
      final rollbackIds = {...state.updatingProductIds}..remove(productId);
      state = state.copyWith(
        status: CartStatus.error,
        items: previousItems,
        summary: _calculateSummary(previousItems),
        updatingProductIds: rollbackIds,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
    }
  }

  Future<void> removeItem(String productId) async {
    if (state.isUpdating(productId)) return;

    final previousItems = List<CartItem>.from(state.items);
    final optimisticItems = state.items.where((e) => e.productId != productId).toList();
    final updatingIds = {...state.updatingProductIds, productId};

    state = state.copyWith(
      status: CartStatus.updating,
      items: optimisticItems,
      summary: _calculateSummary(optimisticItems),
      updatingProductIds: updatingIds,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await ref.read(removeCartItemUseCaseProvider).call(productId);
      final doneIds = {...state.updatingProductIds}..remove(productId);
      state = state.copyWith(
        status: CartStatus.loaded,
        updatingProductIds: doneIds,
      );
    } catch (e) {
      final rollbackIds = {...state.updatingProductIds}..remove(productId);
      state = state.copyWith(
        status: CartStatus.error,
        items: previousItems,
        summary: _calculateSummary(previousItems),
        updatingProductIds: rollbackIds,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
    }
  }

  Future<void> clearCart() async {
    final previousItems = List<CartItem>.from(state.items);

    state = state.copyWith(status: CartStatus.clearing, clearError: true, clearSuccess: true);
    try {
      await ref.read(clearCartUseCaseProvider).call();
      state = state.copyWith(
        status: CartStatus.loaded,
        items: const [],
        summary: const CartSummary.empty(),
        successMessage: 'Cart cleared',
      );
    } catch (e) {
      state = state.copyWith(
        status: CartStatus.error,
        items: previousItems,
        summary: _calculateSummary(previousItems),
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
    }
  }

  Future<String?> validateCheckout() async {
    if (state.items.isEmpty) {
      return 'Your cart is empty.';
    }

    final userId = await _getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      return 'Please login to continue checkout.';
    }

    final unavailable = state.items.where((i) => !i.isAvailable).toList();
    if (unavailable.isNotEmpty) {
      return 'Some products are no longer available.';
    }

    final ownItems = state.items.where((i) => i.sellerId.isNotEmpty && i.sellerId == userId).toList();
    if (ownItems.isNotEmpty) {
      return 'You cannot buy your own product(s).';
    }

    return null;
  }

  Future<String?> validateSingleItemCheckout(CartItem item) async {
    final userId = await _getCurrentUserId();
    if (userId == null || userId.isEmpty) {
      return 'Please login to continue checkout.';
    }

    if (!item.isAvailable) {
      return 'This product is no longer available.';
    }

    if (item.sellerId.isNotEmpty && item.sellerId == userId) {
      return 'You cannot buy your own product.';
    }

    return null;
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true, unauthorized: false);
  }

  CartSummary _calculateSummary(List<CartItem> items) {
    final subtotal = items.fold<double>(0, (sum, item) => sum + (item.productPrice * item.quantity));
    final totalQuantity = items.fold<int>(0, (sum, item) => sum + item.quantity);
    return CartSummary(
      subtotal: subtotal,
      totalItems: items.length,
      totalQuantity: totalQuantity,
    );
  }

  bool _isUnauthorized(Object error) {
    final message = _msg(error).toLowerCase();
    return message.contains('401') || message.contains('unauthorized');
  }

  String _msg(Object e) {
    return e.toString().replaceAll('Exception: ', '').trim();
  }

  bool _looksLikeDuplicateKey(String message) {
    final lower = message.toLowerCase();
    return lower.contains('duplicate key') ||
        lower.contains('e11000') ||
        lower.contains('already exists');
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
