import '../repositories/cart_repository.dart';

class UpdateCartQuantityUseCase {
  final CartRepository repository;

  UpdateCartQuantityUseCase(this.repository);

  Future<void> call(String productId, int quantity) {
    return repository.updateCartQuantity(productId, quantity);
  }
}
