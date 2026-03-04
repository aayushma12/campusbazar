import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/dashboard_product_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetProductsUseCase {
  final DashboardRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<DashboardProduct>>> call({
    int page = 1,
    int limit = 20,
  }) {
    return repository.getProducts(page: page, limit: limit);
  }
}
