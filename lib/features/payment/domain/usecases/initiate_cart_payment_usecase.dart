import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class InitiateCartPaymentUseCase {
  final PaymentRepository repository;

  InitiateCartPaymentUseCase(this.repository);

  Future<Payment> call(List<Map<String, dynamic>> cartItems) {
    return repository.initiateCartPayment(cartItems);
  }
}
