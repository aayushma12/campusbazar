import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class VerifyPaymentUseCase {
  final PaymentRepository repository;

  VerifyPaymentUseCase(this.repository);

  Future<Payment> call({
    required String transactionId,
    required String amount,
    required String transactionCode,
  }) {
    return repository.verifyPayment(
      transactionId: transactionId,
      amount: amount,
      transactionCode: transactionCode,
    );
  }
}
