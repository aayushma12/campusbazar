import '../repositories/booking_repository.dart';

class ConfirmBookingPaymentUseCase {
  final BookingRepository repository;

  ConfirmBookingPaymentUseCase(this.repository);

  Future<void> call(
    String bookingId, {
    required String transactionCode,
    required String transactionUUID,
    required String amount,
  }) {
    return repository.confirmBookingPayment(
      bookingId,
      transactionCode: transactionCode,
      transactionUUID: transactionUUID,
      amount: amount,
    );
  }
}
