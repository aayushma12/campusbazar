import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_product_entity.dart';
import '../repositories/dashboard_repository.dart';

class CreateProductUseCase {
  final DashboardRepository repository;

  CreateProductUseCase(this.repository);

  Future<Either<Failure, DashboardProduct>> call({
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String campus,
    required String condition,
    required bool negotiable,
    required List<File> imageFiles,
  }) {
    return repository.createProduct(
      title: title,
      description: description,
      price: price,
      categoryId: categoryId,
      campus: campus,
      condition: condition,
      negotiable: negotiable,
      imageFiles: imageFiles,
    );
  }
}
