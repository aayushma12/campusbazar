import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';

class UpdateProductUseCase {
  final ProductsRepository repository;

  UpdateProductUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call({
    required String id,
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String condition,
    required String campus,
    required bool negotiable,
  }) {
    return repository.updateProduct(
      id: id,
      title: title,
      description: description,
      price: price,
      categoryId: categoryId,
      condition: condition,
      campus: campus,
      negotiable: negotiable,
    );
  }
}
