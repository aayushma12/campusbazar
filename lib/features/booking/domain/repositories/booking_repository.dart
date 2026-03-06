import '../entities/booking_entity.dart';
import '../entities/tutor_request_entity.dart';
import '../../../payment/domain/entities/payment_entity.dart';

abstract class BookingRepository {
  Future<List<TutorRequestEntity>> getTutorRequests();
  Future<TutorRequestEntity> createTutorRequest(TutorRequestEntity request);
  Future<void> acceptTutorRequest(String requestId);

  Future<List<BookingEntity>> getBookings({String role = 'student'});
  Future<BookingEntity> getBookingById(String bookingId);

  Future<Payment> initiateBookingPayment(String bookingId);
  Future<void> confirmBookingPayment(String bookingId, {
    required String transactionCode,
    required String transactionUUID,
    required String amount,
  });

  Future<void> cancelBooking(String bookingId);
  Future<double> fetchWalletBalance();
}
