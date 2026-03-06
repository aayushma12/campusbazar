enum CheckoutPaymentMethod { esewa, cod }

enum CheckoutStatus { idle, processing, success, error }

class CheckoutState {
  final CheckoutStatus status;
  final int quantity;
  final CheckoutPaymentMethod paymentMethod;
  final bool acknowledgedCollegeRule;
  final String? errorMessage;
  final String? successMessage;

  const CheckoutState({
    this.status = CheckoutStatus.idle,
    this.quantity = 1,
    this.paymentMethod = CheckoutPaymentMethod.esewa,
    this.acknowledgedCollegeRule = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isBusy => status == CheckoutStatus.processing;

  CheckoutState copyWith({
    CheckoutStatus? status,
    int? quantity,
    CheckoutPaymentMethod? paymentMethod,
    bool? acknowledgedCollegeRule,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      quantity: quantity ?? this.quantity,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      acknowledgedCollegeRule: acknowledgedCollegeRule ?? this.acknowledgedCollegeRule,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}
