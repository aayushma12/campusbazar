import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_filter_entity.dart';
import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';

class SearchProductsUseCase {
  final ProductsRepository repository;

  SearchProductsUseCase(this.repository);

  Future<Either<Failure, List<ProductEntity>>> call(ProductFilter filter) {
    return repository.getFilteredProducts(filter);
  }
}
