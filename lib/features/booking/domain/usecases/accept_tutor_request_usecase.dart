import '../repositories/booking_repository.dart';

class AcceptTutorRequestUseCase {
  final BookingRepository repository;

  AcceptTutorRequestUseCase(this.repository);

  Future<void> call(String requestId) {
    return repository.acceptTutorRequest(requestId);
  }
}
