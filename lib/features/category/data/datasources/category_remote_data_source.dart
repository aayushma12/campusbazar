import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel> createCategory(String name);
}

class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient _apiClient;
  CategoryRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.categories);
      final data = response.data['data'] as List<dynamic>?;
      return data != null
          ? data.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList()
          : [];
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Failed to fetch categories');
    }
  }

  @override
  Future<CategoryModel> createCategory(String name) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.categories,
        data: {'name': name},
      );

      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid category response');
      }

      return CategoryModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Failed to create category');
    }
  }
}
