import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/wishlist_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<WishlistModel>> getWishlist({int page, int limit});
  Future<void> addToWishlist(String productId);
  Future<void> removeFromWishlist(String productId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final ApiClient apiClient;

  WishlistRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<WishlistModel>> getWishlist({int page = 1, int limit = 50}) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.userFavorites,
        queryParameters: {'page': page, 'limit': limit},
      );
      final body = response.data as Map<String, dynamic>;
      final items = body['data'] as List<dynamic>? ?? const [];
      return items.whereType<Map<String, dynamic>>().map(WishlistModel.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  @override
  Future<void> addToWishlist(String productId) async {
    try {
      await apiClient.post('${ApiEndpoints.userFavorites}/$productId');
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    try {
      await apiClient.delete('${ApiEndpoints.userFavorites}/$productId');
    } on DioException catch (e) {
      throw Exception(_parseError(e));
    }
  }

  String _parseError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final msg = data is Map<String, dynamic> ? data['message']?.toString() : null;

    if (status == 401) return 'Unauthorized. Please login again.';
    if (status == 404) return msg ?? 'Wishlist item not found';
    if (status == 500) return msg ?? 'Server error';
    return msg ?? e.message ?? 'Wishlist request failed';
  }
}
