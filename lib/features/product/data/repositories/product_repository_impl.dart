import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
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
  }) async {
    return _remoteDataSource.fetchProducts(
      search: search,
      category: category,
      campus: campus,
      minPrice: minPrice,
      maxPrice: maxPrice,
      condition: condition,
      status: status,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Product> getProductById(String id) async {
    return _remoteDataSource.getProductById(id);
  }

  @override
  Future<Product> createProduct(Product product) async {
    final model = ProductModel(
      id: product.id,
      title: product.title,
      description: product.description,
      price: product.price,
      negotiable: product.negotiable,
      condition: product.condition,
      categoryId: product.categoryId,
      campus: product.campus,
      images: product.images,
      status: product.status,
      ownerId: product.ownerId,
      views: product.views,
      createdAt: product.createdAt,
    );
    final created = await _remoteDataSource.createProduct(model.toJson());
    return created;
  }

  @override
  Future<Product> updateProduct(Product product) async {
    final model = ProductModel(
      id: product.id,
      title: product.title,
      description: product.description,
      price: product.price,
      negotiable: product.negotiable,
      condition: product.condition,
      categoryId: product.categoryId,
      campus: product.campus,
      images: product.images,
      status: product.status,
      ownerId: product.ownerId,
      views: product.views,
      createdAt: product.createdAt,
    );
    final updated = await _remoteDataSource.updateProduct(product.id, model.toJson());
    return updated;
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _remoteDataSource.deleteProduct(id);
  }

  @override
  Future<void> toggleFavorite(String id) async {
    await _remoteDataSource.toggleFavorite(id);
  }

  @override
  Future<List<Product>> fetchFavorites() async {
    return _remoteDataSource.fetchFavorites();
  }
}
