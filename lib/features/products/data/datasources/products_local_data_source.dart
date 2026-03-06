import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductsLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> products);
  Future<List<ProductModel>> getCachedProducts();
}

class ProductsLocalDataSourceImpl implements ProductsLocalDataSource {
  static const _boxName = 'productsBox';
  static const _cacheKey = 'CACHED_PRODUCTS';

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final box = await _openBox();
    await box.put(_cacheKey, products.map((e) => e.toMap()).toList());
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    final box = await _openBox();
    final raw = box.get(_cacheKey);
    if (raw is List) {
      return raw.whereType<Map>().map((e) => ProductModel.fromMap(e)).toList();
    }
    throw CacheException();
  }
}
