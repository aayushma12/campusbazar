import '../../domain/entities/order_entity.dart';

enum OrderStatusView { initial, loading, success, error }

class OrderState {
  final OrderStatusView status;
  final List<OrderEntity> orders;
  final OrderEntity? selectedOrder;
  final String? errorMessage;
  final bool isLoading;

  const OrderState({
    this.status = OrderStatusView.initial,
    this.orders = const [],
    this.selectedOrder,
    this.errorMessage,
    this.isLoading = false,
  });

  OrderState copyWith({
    OrderStatusView? status,
    List<OrderEntity>? orders,
    OrderEntity? selectedOrder,
    String? errorMessage,
    bool? isLoading,
    bool clearSelectedOrder = false,
    bool clearErrorMessage = false,
  }) {
    return OrderState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      selectedOrder: clearSelectedOrder ? null : (selectedOrder ?? this.selectedOrder),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
