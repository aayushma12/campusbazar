import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/service_locator.dart';
import '../../../order/domain/repositories/order_repository.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../product/domain/entities/product_entity.dart';
import '../state/checkout_state.dart';

final checkoutViewModelProvider =
    NotifierProvider.autoDispose<CheckoutViewModel, CheckoutState>(CheckoutViewModel.new);

class CheckoutResult {
  final OrderEntity? order;
  final bool paidOnline;

  const CheckoutResult({required this.order, required this.paidOnline});
}

class CheckoutViewModel extends AutoDisposeNotifier<CheckoutState> {
  late final OrderRepository _orderRepository;

  @override
  CheckoutState build() {
    _orderRepository = sl<OrderRepository>();
    return const CheckoutState();
  }

  void increaseQuantity() {
    final next = state.quantity + 1;
    if (next > 99) return;
    state = state.copyWith(quantity: next, clearError: true, clearSuccess: true);
  }

  void decreaseQuantity() {
    final next = state.quantity - 1;
    if (next < 1) return;
    state = state.copyWith(quantity: next, clearError: true, clearSuccess: true);
  }

  void setPaymentMethod(CheckoutPaymentMethod method) {
    state = state.copyWith(paymentMethod: method, clearError: true, clearSuccess: true);
  }

  void setAcknowledgedCollegeRule(bool value) {
    state = state.copyWith(acknowledgedCollegeRule: value, clearError: true);
  }

  Future<CheckoutResult?> placeOrder(Product product) async {
    if (!state.acknowledgedCollegeRule) {
      state = state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: 'Please acknowledge college community handover rule.',
      );
      return null;
    }

    state = state.copyWith(
      status: CheckoutStatus.processing,
      clearError: true,
      clearSuccess: true,
    );

    final total = product.price * state.quantity;

    try {
      if (state.paymentMethod == CheckoutPaymentMethod.esewa) {
        await Future<void>.delayed(const Duration(milliseconds: 900));
      }

      final order = await _orderRepository.createOrder(
        productId: product.id,
        price: total,
        quantity: state.quantity,
        paymentMethod: state.paymentMethod == CheckoutPaymentMethod.esewa ? 'eSewa' : 'COD',
        paymentStatus: state.paymentMethod == CheckoutPaymentMethod.esewa ? 'Paid' : 'Pending',
        deliveryNote: 'Students must receive the product within the college community premises.',
        acknowledgedCollegeRule: state.acknowledgedCollegeRule,
        orderStatus: 'pending',
        sellerId: product.ownerId,
      );

      state = state.copyWith(
        status: CheckoutStatus.success,
        successMessage: 'Order placed successfully',
      );

      return CheckoutResult(
        order: order,
        paidOnline: state.paymentMethod == CheckoutPaymentMethod.esewa,
      );
    } catch (e) {
      state = state.copyWith(
        status: CheckoutStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return null;
    }
  }
}
