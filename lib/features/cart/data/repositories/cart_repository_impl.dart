import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/cart_summary_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource _remoteDataSource;
  CartRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CartItem>> getCartItems() => _remoteDataSource.getCartItems();

  @override
  Future<void> addToCart(String productId, int quantity) => _remoteDataSource.addToCart(productId, quantity);

  @override
  Future<void> updateCartQuantity(String productId, int quantity) async {
    final items = await _remoteDataSource.getCartItems();
    final match = _findByProductId(items, productId);
    await _remoteDataSource.updateCartQuantityByItemId(match.id, quantity);
  }

  @override
  Future<void> removeCartItem(String productId) async {
    final items = await _remoteDataSource.getCartItems();
    final match = _findByProductId(items, productId);
    await _remoteDataSource.removeCartItemByItemId(match.id);
  }

  @override
  Future<void> clearCart() => _remoteDataSource.clearCart();

  @override
  Future<CartSummary> getCartSummary() async {
    final items = await _remoteDataSource.getCartItems();

    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.productPrice * item.quantity),
    );
    final totalQuantity = items.fold<int>(0, (sum, item) => sum + item.quantity);

    return CartSummary(
      subtotal: subtotal,
      totalItems: items.length,
      totalQuantity: totalQuantity,
    );
  }

  CartItem _findByProductId(List<CartItem> items, String productId) {
    final index = items.indexWhere((e) => e.productId == productId);
    if (index < 0) {
      throw Exception('Cart item not found');
    }
    return items[index];
  }
}
