import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_entity.dart';
import '../repositories/products_repository.dart';

class CreateProductUseCase {
  final ProductsRepository repository;

  CreateProductUseCase(this.repository);

  Future<Either<Failure, ProductEntity>> call({
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String condition,
    required String campus,
    required bool negotiable,
    required List<File> images,
  }) {
    return repository.createProduct(
      title: title,
      description: description,
      price: price,
      categoryId: categoryId,
      condition: condition,
      campus: campus,
      negotiable: negotiable,
      images: images,
    );
  }
}
