import '../entities/product_filter_entity.dart';

class ClearFilterUseCase {
  ProductFilter call({int limit = 12}) {
    return ProductFilter.initial().copyWith(limit: limit);
  }
}
