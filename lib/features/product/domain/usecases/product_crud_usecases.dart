import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository;
  CreateProductUseCase(this.repository);

  Future<Product> call(Product product) {
    return repository.createProduct(product);
  }
}

class UpdateProductUseCase {
  final ProductRepository repository;
  UpdateProductUseCase(this.repository);

  Future<Product> call(Product product) {
    return repository.updateProduct(product);
  }
}

class DeleteProductUseCase {
  final ProductRepository repository;
  DeleteProductUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteProduct(id);
  }
}

class ToggleFavoriteUseCase {
  final ProductRepository repository;
  ToggleFavoriteUseCase(this.repository);

  Future<void> call(String id) {
    return repository.toggleFavorite(id);
  }
}

class FetchFavoritesUseCase {
  final ProductRepository repository;
  FetchFavoritesUseCase(this.repository);

  Future<List<Product>> call() {
    return repository.fetchFavorites();
  }
}
