import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addToCart(String productId, int quantity);
  Future<void> updateCartQuantityByItemId(String cartItemId, int quantity);
  Future<void> removeCartItemByItemId(String cartItemId);
  Future<void> clearCart();
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final ApiClient _apiClient;
  CartRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<CartItemModel>> getCartItems() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.cart);
      final body = response.data as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>? ?? const [];
      return list.whereType<Map<String, dynamic>>().map(CartItemModel.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to fetch cart'));
    }
  }

  @override
  Future<void> addToCart(String productId, int quantity) async {
    try {
      await _apiClient.post(ApiEndpoints.cart, data: {'productId': productId, 'quantity': quantity});
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to add to cart'));
    }
  }

  @override
  Future<void> updateCartQuantityByItemId(String cartItemId, int quantity) async {
    try {
      await _apiClient.patch('${ApiEndpoints.cart}/$cartItemId', data: {'quantity': quantity});
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to update quantity'));
    }
  }

  @override
  Future<void> removeCartItemByItemId(String cartItemId) async {
    try {
      await _apiClient.delete('${ApiEndpoints.cart}/$cartItemId');
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to remove item'));
    }
  }

  @override
  Future<void> clearCart() async {
    try {
      await _apiClient.delete(ApiEndpoints.cart);
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to clear cart'));
    }
  }

  String _parseError(DioException e, {required String fallback}) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    final message = data is Map<String, dynamic> ? data['message']?.toString() : null;

    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check backend is running and network/port mapping is correct.';
    }
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Server connection timed out. Please try again.';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server response timed out. Please try again.';
    }

    if (statusCode == 401) return 'Unauthorized. Please login again.';
    if (statusCode == 400) return message ?? 'Invalid cart request.';
    if (statusCode == 500) return message ?? 'Server error. Please try again.';
    return message ?? e.message ?? fallback;
  }
}
