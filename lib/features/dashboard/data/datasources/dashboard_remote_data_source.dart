import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/dashboard_product_model.dart';

abstract class DashboardRemoteDataSource {
  Future<List<DashboardProductModel>> getProducts({
    int page,
    int limit,
  });

  Future<DashboardProductModel> createProduct({
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

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<DashboardProductModel>> getProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.listings,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final body = response.data as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>? ?? const [];

      return list
          .whereType<Map<String, dynamic>>()
          .map(DashboardProductModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (_) {
      throw Exception('Failed to load products');
    }
  }

  @override
  Future<DashboardProductModel> createProduct({
    required String title,
    required String description,
    required double price,
    required String categoryId,
    required String campus,
    required String condition,
    required bool negotiable,
    required List<File> imageFiles,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'campus': campus,
        'condition': condition,
        'negotiable': negotiable,
      });

      for (final image in imageFiles) {
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(image.path),
          ),
        );
      }

      final response = await apiClient.post(ApiEndpoints.listings, data: formData);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;

      if (data == null) {
        throw Exception('Invalid create product response');
      }

      return DashboardProductModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_extractError(e));
    } catch (_) {
      throw Exception('Failed to create product');
    }
  }

  String _extractError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = (data is Map<String, dynamic>) ? data['message']?.toString() : null;

    if (statusCode == 401) return '401 Unauthorized';
    if (message != null && message.isNotEmpty) return message;
    return e.message ?? 'Request failed';
  }
}
