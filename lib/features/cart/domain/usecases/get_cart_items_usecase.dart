import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartItemsUseCase {
  final CartRepository repository;

  GetCartItemsUseCase(this.repository);

  Future<List<CartItem>> call() {
    return repository.getCartItems();
  }
}
