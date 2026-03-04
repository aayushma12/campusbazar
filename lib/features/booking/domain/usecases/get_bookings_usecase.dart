import '../entities/booking_entity.dart';
import '../repositories/booking_repository.dart';

class GetBookingsUseCase {
  final BookingRepository repository;

  GetBookingsUseCase(this.repository);

  Future<List<BookingEntity>> call({String role = 'student'}) {
    return repository.getBookings(role: role);
  }
}
