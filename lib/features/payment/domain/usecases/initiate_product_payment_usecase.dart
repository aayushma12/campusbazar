import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class InitiateProductPaymentUseCase {
  final PaymentRepository repository;

  InitiateProductPaymentUseCase(this.repository);

  Future<Payment> call(String productId) {
    return repository.initiateProductPayment(productId);
  }
}
