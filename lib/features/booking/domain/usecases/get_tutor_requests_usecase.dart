import '../entities/tutor_request_entity.dart';
import '../repositories/booking_repository.dart';

class GetTutorRequestsUseCase {
  final BookingRepository repository;

  GetTutorRequestsUseCase(this.repository);

  Future<List<TutorRequestEntity>> call() {
    return repository.getTutorRequests();
  }
}
