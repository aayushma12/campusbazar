import '../repositories/password_reset_repository.dart';

class VerifyOTPUseCase {
  final PasswordResetRepository repository;

  VerifyOTPUseCase(this.repository);

  Future<void> call(String email, String otp) {
    return repository.verifyOTP(email, otp);
  }
}
