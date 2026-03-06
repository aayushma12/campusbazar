import '../../domain/repositories/password_reset_repository.dart';
import '../datasources/password_reset_remote_data_source.dart';

class PasswordResetRepositoryImpl implements PasswordResetRepository {
  final PasswordResetRemoteDataSource remote;

  PasswordResetRepositoryImpl(this.remote);

  @override
  Future<void> requestPasswordReset(String email) {
    return remote.requestPasswordReset(email);
  }

  @override
  Future<void> verifyOTP(String email, String otp) {
    return remote.verifyOTP(email, otp);
  }

  @override
  Future<void> resetPassword(String email, String newPassword, String otpOrToken) {
    return remote.resetPassword(email, newPassword, otpOrToken);
  }
}
