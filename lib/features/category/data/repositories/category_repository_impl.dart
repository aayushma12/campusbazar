import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_remote_data_source.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource _remoteDataSource;
  CategoryRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CategoryEntity>> getCategories() => _remoteDataSource.getCategories();

  @override
  Future<CategoryEntity> createCategory(String name) => _remoteDataSource.createCategory(name);
}
