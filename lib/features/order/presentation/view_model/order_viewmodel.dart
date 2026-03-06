import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/order_repository.dart';
import '../state/order_state.dart';
import '../../../../core/services/service_locator.dart';

final orderViewModelProvider = NotifierProvider<OrderViewModel, OrderState>(
  OrderViewModel.new,
);

class OrderViewModel extends Notifier<OrderState> {
  late final OrderRepository _repository;

  @override
  OrderState build() {
    _repository = sl<OrderRepository>();
    return const OrderState();
  }

  Future<void> loadOrders({String? type}) async {
    state = state.copyWith(status: OrderStatusView.loading, isLoading: true);
    try {
      final data = await _repository.getOrders(type: type);
      state = state.copyWith(status: OrderStatusView.success, orders: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(status: OrderStatusView.error, errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> loadOrderDetail(String id) async {
    state = state.copyWith(
      status: OrderStatusView.loading,
      isLoading: true,
      clearSelectedOrder: true,
      clearErrorMessage: true,
    );
    try {
      final data = await _repository.getOrderById(id);
      state = state.copyWith(
        status: OrderStatusView.success,
        selectedOrder: data,
        isLoading: false,
        clearErrorMessage: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: OrderStatusView.error,
        errorMessage: e.toString(),
        isLoading: false,
        clearSelectedOrder: true,
      );
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _repository.updateOrderStatus(id, status);
      await loadOrderDetail(id);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<bool> createOrder({
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
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _repository.createOrder(
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
      state = state.copyWith(isLoading: false);
      await loadOrders(type: 'buyer');
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}
