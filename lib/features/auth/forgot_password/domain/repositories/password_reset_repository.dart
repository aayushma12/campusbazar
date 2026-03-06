abstract class PasswordResetRepository {
  Future<void> requestPasswordReset(String email);
  Future<void> verifyOTP(String email, String otp);
  Future<void> resetPassword(String email, String newPassword, String otpOrToken);
}
