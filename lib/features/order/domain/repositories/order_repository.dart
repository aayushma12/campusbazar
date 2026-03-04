import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders({String? type});
  Future<OrderEntity> getOrderById(String id);
  Future<List<OrderEntity>> createBulkCodOrders({
    required List<Map<String, dynamic>> items,
  });
  Future<OrderEntity> createOrder({
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
