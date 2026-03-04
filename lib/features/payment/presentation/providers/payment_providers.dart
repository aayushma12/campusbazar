import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/api/api_client.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../data/datasources/payment_remote_data_source.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/get_payment_history_usecase.dart';
import '../../domain/usecases/initiate_booking_payment_usecase.dart';
import '../../domain/usecases/initiate_cart_payment_usecase.dart';
import '../../domain/usecases/initiate_product_payment_usecase.dart';
import '../../domain/usecases/verify_payment_usecase.dart';
import 'payment_state.dart';

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(
    remote: PaymentRemoteDataSourceImpl(apiClient: GetIt.instance<ApiClient>()),
  );
});

final initiateProductPaymentUseCaseProvider = Provider<InitiateProductPaymentUseCase>((ref) {
  return InitiateProductPaymentUseCase(ref.read(paymentRepositoryProvider));
});

final initiateCartPaymentUseCaseProvider = Provider<InitiateCartPaymentUseCase>((ref) {
  return InitiateCartPaymentUseCase(ref.read(paymentRepositoryProvider));
});

final initiateBookingPaymentUseCaseProvider = Provider<InitiateBookingPaymentUseCase>((ref) {
  return InitiateBookingPaymentUseCase(ref.read(paymentRepositoryProvider));
});

final verifyPaymentUseCaseProvider = Provider<VerifyPaymentUseCase>((ref) {
  return VerifyPaymentUseCase(ref.read(paymentRepositoryProvider));
});

final getPaymentHistoryUseCaseProvider = Provider<GetPaymentHistoryUseCase>((ref) {
  return GetPaymentHistoryUseCase(ref.read(paymentRepositoryProvider));
});

final paymentNotifierProvider = NotifierProvider<PaymentNotifier, PaymentState>(PaymentNotifier.new);

class PaymentNotifier extends Notifier<PaymentState> {
  static const Duration _requestTimeout = Duration(seconds: 30);

  @override
  PaymentState build() => const PaymentState();

  Future<Payment?> initiateProductPayment(String productId) async {
    if (state.isBusy) return null;

    state = state.copyWith(
      status: PaymentStateStatus.initiating,
      activeFlow: PaymentFlowType.product,
      clearError: true,
      clearInfo: true,
      unauthorized: false,
    );

    try {
      final payment = await ref
          .read(initiateProductPaymentUseCaseProvider)
          .call(productId)
          .timeout(_requestTimeout);
      state = state.copyWith(
        status: PaymentStateStatus.redirecting,
        currentPayment: payment,
        infoMessage: 'Redirecting to eSewa...',
      );
      return payment;
    } catch (e) {
      state = state.copyWith(
        status: PaymentStateStatus.error,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
      return null;
    }
  }

  Future<Payment?> initiateCartPayment(List<CartItem> items) async {
    if (state.isBusy) return null;

    state = state.copyWith(
      status: PaymentStateStatus.initiating,
      activeFlow: PaymentFlowType.cart,
      clearError: true,
      clearInfo: true,
      unauthorized: false,
    );

    try {
      final payload = items
          .map(
            (e) => {
              'productId': {
                '_id': e.productId,
                'price': e.productPrice,
                'ownerId': e.sellerId,
              },
              'quantity': e.quantity,
            },
          )
          .toList();

      final payment = await ref
          .read(initiateCartPaymentUseCaseProvider)
          .call(payload)
          .timeout(_requestTimeout);
      state = state.copyWith(
        status: PaymentStateStatus.redirecting,
        currentPayment: payment,
        infoMessage: 'Redirecting to eSewa...',
      );
      return payment;
    } catch (e) {
      state = state.copyWith(
        status: PaymentStateStatus.error,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
      return null;
    }
  }

  Future<Payment?> initiateBookingPayment(String bookingId, double amount) async {
    if (state.isBusy) return null;

    state = state.copyWith(
      status: PaymentStateStatus.initiating,
      activeFlow: PaymentFlowType.booking,
      clearError: true,
      clearInfo: true,
      unauthorized: false,
    );

    try {
      final payment = await ref
          .read(initiateBookingPaymentUseCaseProvider)
          .call(bookingId, amount)
          .timeout(_requestTimeout);
      state = state.copyWith(
        status: PaymentStateStatus.redirecting,
        currentPayment: payment,
        infoMessage: 'Redirecting to eSewa...',
      );
      return payment;
    } catch (e) {
      state = state.copyWith(
        status: PaymentStateStatus.error,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
      return null;
    }
  }

  Future<Payment?> verifyPayment({
    required String transactionId,
    required String amount,
    required String transactionCode,
    required PaymentFlowType flowType,
    String? purchasedProductId,
  }) async {
    if (state.status == PaymentStateStatus.verifying) return null;

    state = state.copyWith(
      status: PaymentStateStatus.verifying,
      activeFlow: flowType,
      clearError: true,
      clearInfo: true,
      unauthorized: false,
    );

    try {
      final verified = await ref.read(verifyPaymentUseCaseProvider).call(
            transactionId: transactionId,
            amount: amount,
            transactionCode: transactionCode,
          ).timeout(_requestTimeout);

      state = state.copyWith(
        status: PaymentStateStatus.success,
        currentPayment: verified,
        infoMessage: 'Payment verified successfully.',
      );

      if (flowType == PaymentFlowType.cart) {
        await ref.read(cartNotifierProvider.notifier).clearCart();
        await ref.read(cartNotifierProvider.notifier).loadCart();
      }

      if (flowType == PaymentFlowType.cartItem && purchasedProductId != null && purchasedProductId.isNotEmpty) {
        await ref.read(cartNotifierProvider.notifier).removeItem(purchasedProductId);
        await ref.read(cartNotifierProvider.notifier).loadCart();
      }

      return verified;
    } catch (e) {
      state = state.copyWith(
        status: PaymentStateStatus.failure,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
      return null;
    }
  }

  Future<void> fetchHistory() async {
    state = state.copyWith(
      status: PaymentStateStatus.initiating,
      clearError: true,
      clearInfo: true,
      unauthorized: false,
    );

    try {
      final history = await ref.read(getPaymentHistoryUseCaseProvider).call();
      state = state.copyWith(
        status: PaymentStateStatus.success,
        history: history,
      );
    } catch (e) {
      state = state.copyWith(
        status: PaymentStateStatus.error,
        errorMessage: _msg(e),
        unauthorized: _isUnauthorized(e),
      );
    }
  }

  void markRedirecting() {
    state = state.copyWith(status: PaymentStateStatus.redirecting, clearError: true);
  }

  void markFailure(String message) {
    state = state.copyWith(status: PaymentStateStatus.failure, errorMessage: message);
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearInfo: true, unauthorized: false);
  }

  void resetFlow({String? infoMessage}) {
    state = state.copyWith(
      status: PaymentStateStatus.initial,
      clearError: true,
      clearInfo: infoMessage == null,
      infoMessage: infoMessage,
      clearPayment: true,
      activeFlow: null,
      unauthorized: false,
    );
  }

  String _msg(Object e) {
    if (e is TimeoutException) {
      return 'Payment service timeout. Please check your connection and try again.';
    }

    return e.toString().replaceAll('Exception: ', '').trim();
  }

  bool _isUnauthorized(Object e) {
    final msg = _msg(e).toLowerCase();
    return msg.contains('401') || msg.contains('unauthorized');
  }
}
