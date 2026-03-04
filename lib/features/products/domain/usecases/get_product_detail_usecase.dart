import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';

class GetProductDetailUseCase {
  final ProductsRepository repository;

  GetProductDetailUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call(String id) {
    return repository.getProductById(id);
  }
}
