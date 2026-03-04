import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/dashboard_product_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_data_source.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final DashboardLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<DashboardProduct>>> getProducts({
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remote = await remoteDataSource.getProducts(page: page, limit: limit);
        await localDataSource.cacheProducts(remote);
        return Right(remote);
      } catch (e) {
        final msg = _message(e);
        if (_isUnauthorized(msg)) {
          return const Left(ServerFailure('Unauthorized. Please login again.'));
        }

        try {
          final local = await localDataSource.getCachedProducts();
          return Right(local);
        } catch (_) {
          return Left(ServerFailure(msg));
        }
      }
    }

    try {
      final local = await localDataSource.getCachedProducts();
      return Right(local);
    } catch (_) {
      return const Left(CacheFailure('No cached products found.'));
    }
  }

  @override
  Future<Either<Failure, DashboardProduct>> createProduct({
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String campus,
    required String condition,
    required bool negotiable,
    required List<File> imageFiles,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(ServerFailure('No internet connection.'));
    }

    try {
      final created = await remoteDataSource.createProduct(
        title: title,
        description: description,
        price: price,
        categoryId: categoryId,
        campus: campus,
        condition: condition,
        negotiable: negotiable,
        imageFiles: imageFiles,
      );

      try {
        final cached = await localDataSource.getCachedProducts();
        await localDataSource.cacheProducts([created, ...cached]);
      } catch (_) {
        await localDataSource.cacheProducts([created]);
      }

      return Right(created);
    } catch (e) {
      final msg = _message(e);
      if (_isUnauthorized(msg)) {
        return const Left(ServerFailure('Unauthorized. Please login again.'));
      }
      return Left(ServerFailure(msg));
    }
  }

  String _message(Object e) {
    final m = e.toString().replaceAll('Exception: ', '').trim();
    return m.isEmpty ? 'Something went wrong' : m;
  }

  bool _isUnauthorized(String message) {
    final m = message.toLowerCase();
    return m.contains('401') || m.contains('unauthorized');
  }
}
