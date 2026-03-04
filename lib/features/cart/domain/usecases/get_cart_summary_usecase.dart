import '../entities/cart_summary_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartSummaryUseCase {
  final CartRepository repository;

  GetCartSummaryUseCase(this.repository);

  Future<CartSummary> call() {
    return repository.getCartSummary();
  }
}
