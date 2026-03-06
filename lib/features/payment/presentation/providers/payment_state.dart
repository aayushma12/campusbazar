import '../../domain/entities/payment_entity.dart';

enum PaymentStateStatus {
  initial,
  initiating,
  redirecting,
  verifying,
  success,
  failure,
  error,
}

class PaymentState {
  final PaymentStateStatus status;
  final Payment? currentPayment;
  final List<Payment> history;
  final bool unauthorized;
  final String? errorMessage;
  final String? infoMessage;
  final PaymentFlowType? activeFlow;

  const PaymentState({
    this.status = PaymentStateStatus.initial,
    this.currentPayment,
    this.history = const [],
    this.unauthorized = false,
    this.errorMessage,
    this.infoMessage,
    this.activeFlow,
  });

  bool get isBusy =>
      status == PaymentStateStatus.initiating ||
      status == PaymentStateStatus.redirecting ||
      status == PaymentStateStatus.verifying;

    bool get isCartFlowBusy =>
      isBusy &&
      (activeFlow == PaymentFlowType.cart || activeFlow == PaymentFlowType.cartItem);

  PaymentState copyWith({
    PaymentStateStatus? status,
    Payment? currentPayment,
    List<Payment>? history,
    bool? unauthorized,
    String? errorMessage,
    String? infoMessage,
    PaymentFlowType? activeFlow,
    bool clearError = false,
    bool clearInfo = false,
    bool clearPayment = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      currentPayment: clearPayment ? null : (currentPayment ?? this.currentPayment),
      history: history ?? this.history,
      unauthorized: unauthorized ?? this.unauthorized,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      activeFlow: activeFlow ?? this.activeFlow,
    );
  }
}
