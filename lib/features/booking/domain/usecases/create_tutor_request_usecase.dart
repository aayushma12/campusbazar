import '../entities/tutor_request_entity.dart';
import '../repositories/booking_repository.dart';

class CreateTutorRequestUseCase {
  final BookingRepository repository;

  CreateTutorRequestUseCase(this.repository);

  Future<TutorRequestEntity> call(TutorRequestEntity request) {
    return repository.createTutorRequest(request);
  }
}
