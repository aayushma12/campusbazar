import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/products_repository.dart';

class GetProductsUseCase {
  final ProductsRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, PaginatedProducts>> call({
    required int page,
    required int limit,
  }) {
    return repository.getProducts(page: page, limit: limit);
  }
}
