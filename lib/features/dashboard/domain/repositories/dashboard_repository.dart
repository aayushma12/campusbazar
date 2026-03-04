import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_product_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, List<DashboardProduct>>> getProducts({
    int page,
    int limit,
  });

  Future<Either<Failure, DashboardProduct>> createProduct({
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String campus,
    required String condition,
    required bool negotiable,
    required List<File> imageFiles,
  });
}
