import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductUseCase {
  final ProductRepository repository;
  GetProductUseCase(this.repository);

  Future<Product> call(String id) {
    return repository.getProductById(id);
  }
}
