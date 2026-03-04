import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/product_filter_entity.dart';
import '../entities/product_entity.dart';

class PaginatedProducts {
  final List<ProductEntity> products;
  final int currentPage;
  final int totalPages;
  final int totalItems;

  const PaginatedProducts({
    required this.products,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
  });
}

abstract class ProductsRepository {
  Future<Either<Failure, PaginatedProducts>> getProducts({
    required int page,
    required int limit,
  });

  Future<Either<Failure, ProductEntity>> getProductById(String id);

  Future<Either<Failure, List<ProductEntity>>> getFilteredProducts(ProductFilter filter);

  Future<Either<Failure, ProductEntity>> createProduct({
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String condition,
    required String campus,
    required bool negotiable,
    required List<File> images,
  });

  Future<Either<Failure, ProductEntity>> updateProduct({
    required String id,
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String condition,
    required String campus,
    required bool negotiable,
  });

  Future<Either<Failure, void>> deleteProduct(String productId);
}
