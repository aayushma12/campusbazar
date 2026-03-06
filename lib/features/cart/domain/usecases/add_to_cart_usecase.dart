import '../repositories/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<void> call(String productId, int quantity) {
    return repository.addToCart(productId, quantity);
  }
}
