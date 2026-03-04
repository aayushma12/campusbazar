import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product_filter_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_local_data_source.dart';
import '../datasources/products_remote_data_source.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource remote;
  final ProductsLocalDataSource local;
  final NetworkInfo networkInfo;

  ProductsRepositoryImpl({
    required this.remote,
    required this.local,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, PaginatedProducts>> getProducts({required int page, required int limit}) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remote.getProducts(page: page, limit: limit);
        if (page == 1) {
          await local.cacheProducts(response.products);
        }

        return Right(
          PaginatedProducts(
            products: response.products,
            currentPage: response.page,
            totalPages: response.totalPages,
            totalItems: response.total,
          ),
        );
      } catch (e) {
        final msg = _message(e);
        if (_unauthorized(msg)) {
          return const Left(ServerFailure('Unauthorized. Please login again.'));
        }

        if (page == 1) {
          try {
            final cached = await local.getCachedProducts();
            return Right(
              PaginatedProducts(
                products: cached,
                currentPage: 1,
                totalPages: 1,
                totalItems: cached.length,
              ),
            );
          } catch (_) {}
        }

        return Left(ServerFailure(msg));
      }
    }

    try {
      final cached = await local.getCachedProducts();
      return Right(
        PaginatedProducts(
          products: cached,
          currentPage: 1,
          totalPages: 1,
          totalItems: cached.length,
        ),
      );
    } catch (_) {
      return const Left(CacheFailure('No cached products available.'));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final product = await remote.getProductById(id);
      return Right(product);
    } catch (e) {
      final msg = _message(e);
      if (_unauthorized(msg)) {
        return const Left(ServerFailure('Unauthorized. Please login again.'));
      }
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFilteredProducts(ProductFilter filter) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remote.getFilteredProducts(filter);
        if (filter.page == 1) {
          await local.cacheProducts(response.products);
        }
        return Right(response.products);
      } catch (e) {
        final msg = _message(e);
        if (_unauthorized(msg)) {
          return const Left(ServerFailure('Unauthorized. Please login again.'));
        }

        if (filter.page == 1) {
          try {
            final cached = await local.getCachedProducts();
            return Right(cached);
          } catch (_) {}
        }

        return Left(ServerFailure(msg));
      }
    }

    if (filter.page == 1) {
      try {
        final cached = await local.getCachedProducts();
        return Right(cached);
      } catch (_) {
        return const Left(CacheFailure('No cached products available.'));
      }
    }

    return const Right([]);
  }

  @override
  Future<Either<Failure, ProductEntity>> createProduct({
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String condition,
    required String campus,
    required bool negotiable,
    required List<File> images,
  }) async {
    try {
      final created = await remote.createProduct(
        title: title,
        description: description,
        price: price,
        categoryId: categoryId,
        condition: condition,
        campus: campus,
        negotiable: negotiable,
        images: images,
      );
      return Right(created);
    } catch (e) {
      final msg = _message(e);
      if (_unauthorized(msg)) {
        return const Left(ServerFailure('Unauthorized. Please login again.'));
      }
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, ProductEntity>> updateProduct({
    required String id,
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String condition,
    required String campus,
    required bool negotiable,
  }) async {
    try {
      final updated = await remote.updateProduct(
        id: id,
        title: title,
        description: description,
        price: price,
        categoryId: categoryId,
        condition: condition,
        campus: campus,
        negotiable: negotiable,
      );
      return Right(updated);
    } catch (e) {
      final msg = _message(e);
      if (_unauthorized(msg)) {
        return const Left(ServerFailure('Unauthorized. Please login again.'));
      }
      return Left(ServerFailure(msg));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String productId) async {
    try {
      await remote.deleteProduct(productId);
      return const Right(null);
    } catch (e) {
      final msg = _message(e);
      if (_unauthorized(msg)) {
        return const Left(ServerFailure('Unauthorized. Please login again.'));
      }
      return Left(ServerFailure(msg));
    }
  }

  String _message(Object e) {
    final text = e.toString().replaceAll('Exception: ', '').trim();
    return text.isEmpty ? 'Request failed' : text;
  }

  bool _unauthorized(String message) {
    final m = message.toLowerCase();
    return m.contains('401') || m.contains('unauthorized');
  }
}
