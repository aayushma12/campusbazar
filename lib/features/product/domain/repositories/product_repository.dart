import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchProducts({
    String? search,
    String? category,
    String? campus,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? status,
    int page = 1,
    int limit = 20,
  });

  Future<Product> getProductById(String id);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<void> deleteProduct(String id);
  Future<void> toggleFavorite(String id);
  Future<List<Product>> fetchFavorites();
}
