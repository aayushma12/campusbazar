import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders({String? type});
  Future<OrderModel> getOrderById(String id);
  Future<List<OrderModel>> createBulkCodOrders({
    required List<Map<String, dynamic>> items,
  });
  Future<OrderModel> createOrder({
    required String productId,
    required double price,
    int quantity = 1,
    String? paymentMethod,
    String? paymentStatus,
    String? deliveryNote,
    bool? acknowledgedCollegeRule,
    String? orderStatus,
    String? sellerId,
  });
  Future<void> updateOrderStatus(String id, String status);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient _apiClient;
  OrderRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<OrderModel>> getOrders({String? type}) async {
    try {
      final normalizedType = (type ?? 'buyer').toLowerCase();
      final endpoint = normalizedType == 'seller'
          ? '${ApiEndpoints.orders}/my-sales'
          : '${ApiEndpoints.orders}/my-purchases';

      final response = await _apiClient.get(endpoint);
      final body = response.data as Map<String, dynamic>? ?? const {};
      final dynamic raw = body['data'];

      List<dynamic> rows;
      if (raw is List<dynamic>) {
        rows = raw;
      } else if (raw is Map<String, dynamic> && raw['orders'] is List<dynamic>) {
        rows = raw['orders'] as List<dynamic>;
      } else {
        rows = const [];
      }

      return rows
          .whereType<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Failed to fetch orders');
    }
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.orders}/$id');
      final body = response.data as Map<String, dynamic>? ?? const {};
      final dynamic rawData = body['data'];

      final Map<String, dynamic> orderJson;
      if (rawData is Map<String, dynamic>) {
        if (rawData['order'] is Map<String, dynamic>) {
          orderJson = rawData['order'] as Map<String, dynamic>;
        } else {
          orderJson = rawData;
        }
      } else {
        throw Exception('Invalid order response from server');
      }

      return OrderModel.fromJson(orderJson);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Failed to fetch order');
    }
  }

  @override
  Future<OrderModel> createOrder({
    required String productId,
    required double price,
    int quantity = 1,
    String? paymentMethod,
    String? paymentStatus,
    String? deliveryNote,
    bool? acknowledgedCollegeRule,
    String? orderStatus,
    String? sellerId,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.orders,
        data: {
          'productId': productId,
          'price': price,
          'totalPrice': price,
          'quantity': quantity,
          'paymentMethod': paymentMethod,
          'paymentStatus': paymentStatus,
          'deliveryNote': deliveryNote,
          'acknowledgedCollegeRule': acknowledgedCollegeRule,
          'orderStatus': orderStatus,
          'sellerId': sellerId,
        },
      );

      return OrderModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Failed to create order');
    }
  }

  @override
  Future<List<OrderModel>> createBulkCodOrders({
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.orders}/bulk-cod',
        data: {'items': items},
      );

      final body = response.data as Map<String, dynamic>? ?? const {};
      final data = body['data'] as Map<String, dynamic>? ?? const {};
      final rawOrders = data['orders'] as List<dynamic>? ?? const [];

      return rawOrders
          .whereType<Map<String, dynamic>>()
          .map(OrderModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Failed to create bulk COD orders');
    }
  }

  @override
  Future<void> updateOrderStatus(String id, String status) async {
    try {
      final normalized = status.toLowerCase();
      String path;
      Map<String, dynamic>? data;

      switch (normalized) {
        case 'accepted':
        case 'accept':
          path = '${ApiEndpoints.orders}/$id/accept';
          break;
        case 'rejected':
        case 'reject':
          path = '${ApiEndpoints.orders}/$id/reject';
          data = {'reason': 'Rejected by user'};
          break;
        case 'handed_over':
        case 'handed-over':
          path = '${ApiEndpoints.orders}/$id/handed-over';
          break;
        case 'completed':
        case 'complete':
          path = '${ApiEndpoints.orders}/$id/complete';
          break;
        case 'cancelled':
        case 'cancel':
          path = '${ApiEndpoints.orders}/$id/cancel';
          break;
        default:
          throw Exception('Unsupported order status: $status');
      }

      await _apiClient.patch(path, data: data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? e.message ?? 'Failed to update order');
    }
  }
}
