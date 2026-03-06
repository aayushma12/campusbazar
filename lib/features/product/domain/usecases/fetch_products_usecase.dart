import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class FetchProductsParams {
  final String? search;
  final String? category;
  final String? campus;
  final double? minPrice;
  final double? maxPrice;
  final String? condition;
  final String? status;
  final int page;
  final int limit;

  FetchProductsParams({
    this.search,
    this.category,
    this.campus,
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.status,
    this.page = 1,
    this.limit = 20,
  });
}

class FetchProductsUseCase {
  final ProductRepository repository;
  FetchProductsUseCase(this.repository);

  Future<List<Product>> call(FetchProductsParams params) {
    return repository.fetchProducts(
      search: params.search,
      category: params.category,
      campus: params.campus,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      condition: params.condition,
      status: params.status,
      page: params.page,
      limit: params.limit,
    );
  }
}
