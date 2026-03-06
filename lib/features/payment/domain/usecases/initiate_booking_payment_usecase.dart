import '../entities/payment_entity.dart';
import '../repositories/payment_repository.dart';

class InitiateBookingPaymentUseCase {
  final PaymentRepository repository;

  InitiateBookingPaymentUseCase(this.repository);

  Future<Payment> call(String bookingId, double amount) {
    return repository.initiateBookingPayment(bookingId, amount);
  }
}
