import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;
  OrderRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<OrderEntity>> getOrders({String? type}) => _remoteDataSource.getOrders(type: type);

  @override
  Future<OrderEntity> getOrderById(String id) => _remoteDataSource.getOrderById(id);

  @override
  Future<List<OrderEntity>> createBulkCodOrders({
    required List<Map<String, dynamic>> items,
  }) =>
      _remoteDataSource.createBulkCodOrders(items: items);

  @override
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
  }) =>
      _remoteDataSource.createOrder(
        productId: productId,
        price: price,
        quantity: quantity,
        paymentMethod: paymentMethod,
        paymentStatus: paymentStatus,
        deliveryNote: deliveryNote,
        acknowledgedCollegeRule: acknowledgedCollegeRule,
        orderStatus: orderStatus,
        sellerId: sellerId,
      );

  @override
  Future<void> updateOrderStatus(String id, String status) => _remoteDataSource.updateOrderStatus(id, status);
}
