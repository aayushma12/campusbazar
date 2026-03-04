import '../entities/cart_item_entity.dart';
import '../entities/cart_summary_entity.dart';

abstract class CartRepository {
  Future<List<CartItem>> getCartItems();
  Future<void> addToCart(String productId, int quantity);
  Future<void> updateCartQuantity(String productId, int quantity);
  Future<void> removeCartItem(String productId);
  Future<void> clearCart();
  Future<CartSummary> getCartSummary();
}
