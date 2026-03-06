import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/products_repository.dart';

class DeleteProductUseCase {
  final ProductsRepository repository;

  DeleteProductUseCase(this.repository);

  Future<Either<Failure, void>> call(String productId) {
    return repository.deleteProduct(productId);
  }
}
