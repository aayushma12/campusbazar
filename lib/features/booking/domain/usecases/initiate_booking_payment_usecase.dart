import '../../../payment/domain/entities/payment_entity.dart';
import '../repositories/booking_repository.dart';

class InitiateBookingPaymentUseCase {
  final BookingRepository repository;

  InitiateBookingPaymentUseCase(this.repository);

  Future<Payment> call(String bookingId) {
    return repository.initiateBookingPayment(bookingId);
  }
}
