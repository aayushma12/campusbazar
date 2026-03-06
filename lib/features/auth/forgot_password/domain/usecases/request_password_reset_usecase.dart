import '../repositories/password_reset_repository.dart';

class RequestPasswordResetUseCase {
  final PasswordResetRepository repository;

  RequestPasswordResetUseCase(this.repository);

  Future<void> call(String email) {
    return repository.requestPasswordReset(email);
  }
}
