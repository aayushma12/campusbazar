import 'package:hive/hive.dart';

import '../../../../core/error/exceptions.dart';
import '../models/dashboard_product_model.dart';

abstract class DashboardLocalDataSource {
  Future<void> cacheProducts(List<DashboardProductModel> products);
  Future<List<DashboardProductModel>> getCachedProducts();
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  static const _boxName = 'dashboardBox';
  static const _cacheKey = 'CACHED_PRODUCTS';

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }

  @override
  Future<void> cacheProducts(List<DashboardProductModel> products) async {
    final box = await _openBox();
    final mapped = products.map((e) => e.toMap()).toList();
    await box.put(_cacheKey, mapped);
  }

  @override
  Future<List<DashboardProductModel>> getCachedProducts() async {
    final box = await _openBox();
    final raw = box.get(_cacheKey);

    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => DashboardProductModel.fromMap(e))
          .toList();
    }

    throw CacheException();
  }
}
