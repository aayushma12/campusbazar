import '../repositories/password_reset_repository.dart';

class ResetPasswordUseCase {
  final PasswordResetRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call(String email, String newPassword, String otpOrToken) {
    return repository.resetPassword(email, newPassword, otpOrToken);
  }
}
