import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetBookingByIdUseCase {
  final BookingRepository repository;

  GetBookingByIdUseCase(this.repository);

  Future<BookingEntity> call(String bookingId) {
    return repository.getBookingById(bookingId);
  }
}
