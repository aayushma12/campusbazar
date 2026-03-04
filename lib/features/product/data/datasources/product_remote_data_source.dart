import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_client.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> fetchProducts({
    String? search,
    String? category,
    String? campus,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? status,
    int page = 1,
    int limit = 20,
  });

  Future<ProductModel> getProductById(String id);
  Future<ProductModel> createProduct(Map<String, dynamic> body);
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> body);
  Future<void> deleteProduct(String id);
  Future<void> toggleFavorite(String id);
  Future<List<ProductModel>> fetchFavorites();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ProductModel>> fetchProducts({
    String? search,
    String? category,
    String? campus,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;
      if (campus != null) queryParams['campus'] = campus;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      if (condition != null) queryParams['condition'] = condition;
      if (status != null) queryParams['status'] = status;
      queryParams['page'] = page;
      queryParams['limit'] = limit;

      final response = await _apiClient.get(ApiEndpoints.listings, queryParameters: queryParams);
      final data = response.data['data'] as List<dynamic>?;
      return data != null
          ? data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList()
          : [];
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to fetch products';
      throw Exception(message);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.listings}/$id');
      return ProductModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to load product';
      throw Exception(message);
    } catch (e) {
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<ProductModel> createProduct(Map<String, dynamic> body) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.listings, data: body);
      return ProductModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to create product';
      throw Exception(message);
    }
  }

  @override
  Future<ProductModel> updateProduct(String id, Map<String, dynamic> body) async {
    try {
      final response = await _apiClient.patch('${ApiEndpoints.listings}/$id', data: body);
      return ProductModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to update product';
      throw Exception(message);
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.listings}/$id');
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to delete product';
      throw Exception(message);
    }
  }

  @override
  Future<void> toggleFavorite(String id) async {
    try {
      await _apiClient.post('${ApiEndpoints.listings}/$id/favorite');
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to toggle favorite';
      throw Exception(message);
    }
  }

  @override
  Future<List<ProductModel>> fetchFavorites() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.userFavorites);
      final data = response.data['data'] as List<dynamic>?;
      return data != null
          ? data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList()
          : [];
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to fetch favorites';
      throw Exception(message);
    }
  }
}
