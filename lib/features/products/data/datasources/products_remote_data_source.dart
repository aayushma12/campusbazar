import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/product_filter_entity.dart';
import 'product_query_builder.dart';
import '../models/product_model.dart';

abstract class ProductsRemoteDataSource {
  Future<PaginatedProductsModel> getProducts({required int page, required int limit});
  Future<PaginatedProductsModel> getFilteredProducts(ProductFilter filter);
  Future<ProductModel> getProductById(String id);
  Future<ProductModel> createProduct({
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String condition,
    required String campus,
    required bool negotiable,
    required List<File> images,
  });
  Future<ProductModel> updateProduct({
    required String id,
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String condition,
    required String campus,
    required bool negotiable,
  });
  Future<void> deleteProduct(String productId);
}

class ProductsRemoteDataSourceImpl implements ProductsRemoteDataSource {
  final ApiClient apiClient;

  ProductsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedProductsModel> getProducts({required int page, required int limit}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.listings,
        queryParameters: {'page': page, 'limit': limit},
      );
      final body = response.data as Map<String, dynamic>;
      return PaginatedProductsModel.fromJson(body);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  @override
  Future<PaginatedProductsModel> getFilteredProducts(ProductFilter filter) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.listings,
        queryParameters: ProductQueryBuilder.toQuery(filter),
      );
      final body = response.data as Map<String, dynamic>;
      return PaginatedProductsModel.fromJson(body);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await apiClient.get('${ApiEndpoints.listings}/$id');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) throw Exception('Invalid product detail response');
      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  @override
  Future<ProductModel> createProduct({
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
      final form = FormData.fromMap({
        'title': title,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'condition': condition,
        'campus': campus,
        'negotiable': negotiable,
      });

      for (final image in images) {
        form.files.add(MapEntry('images', await MultipartFile.fromFile(image.path)));
      }

      final response = await apiClient.post(ApiEndpoints.listings, data: form);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) throw Exception('Invalid create response');
      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  @override
  Future<ProductModel> updateProduct({
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
      final response = await apiClient.patch(
        '${ApiEndpoints.listings}/$id',
        data: {
          'title': title,
          'description': description,
          'price': price,
          'categoryId': categoryId,
          'condition': condition,
          'campus': campus,
          'negotiable': negotiable,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;
      if (data == null) throw Exception('Invalid update response');
      return ProductModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await apiClient.delete('${ApiEndpoints.listings}/$productId');
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  String _parseError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final msg = data is Map<String, dynamic> ? data['message']?.toString() : null;

    if (status == 400) return msg ?? 'Validation error';
    if (status == 401) return '401 Unauthorized';
    if (status == 500) return msg ?? 'Server error';
    return msg ?? e.message ?? 'Request failed';
  }
}
