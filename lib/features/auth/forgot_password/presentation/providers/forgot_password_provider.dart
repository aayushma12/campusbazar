import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../../../../core/api/api_client.dart';
import '../../data/datasources/password_reset_remote_data_source.dart';
import '../../data/repositories/password_reset_repository_impl.dart';
import '../../domain/repositories/password_reset_repository.dart';
import '../../domain/usecases/request_password_reset_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'forgot_password_state.dart';

final passwordResetRepositoryProvider = Provider<PasswordResetRepository>((ref) {
  final apiClient = GetIt.instance<ApiClient>();
  return PasswordResetRepositoryImpl(PasswordResetRemoteDataSourceImpl(apiClient));
});

final requestPasswordResetUseCaseProvider = Provider<RequestPasswordResetUseCase>((ref) {
  return RequestPasswordResetUseCase(ref.read(passwordResetRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyOTPUseCase>((ref) {
  return VerifyOTPUseCase(ref.read(passwordResetRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.read(passwordResetRepositoryProvider));
});

final forgotPasswordNotifierProvider = NotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
  ForgotPasswordNotifier.new,
);

class ForgotPasswordNotifier extends Notifier<ForgotPasswordState> {
  static const _resetEmailCacheKey = 'RESET_EMAIL_PREFILL';

  @override
  ForgotPasswordState build() {
    final cachedEmail = _readCachedEmail();
    return ForgotPasswordState(email: cachedEmail);
  }

  Future<void> requestPasswordReset(String email) async {
    state = state.copyWith(
      forgotStatus: ForgotPasswordStateStatus.loading,
      resetStatus: ResetPasswordStateStatus.initial,
      email: email,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await ref.read(requestPasswordResetUseCaseProvider).call(email);
      await _cacheEmail(email);
      state = state.copyWith(
        forgotStatus: ForgotPasswordStateStatus.otpSent,
        successMessage: 'OTP sent to your email.',
      );
    } catch (e) {
      state = state.copyWith(
        forgotStatus: ForgotPasswordStateStatus.error,
        errorMessage: _msg(e),
      );
    }
  }

  Future<void> verifyOtp(String email, String otp) async {
    state = state.copyWith(
      forgotStatus: ForgotPasswordStateStatus.loading,
      email: email,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await ref.read(verifyOtpUseCaseProvider).call(email, otp);
      state = state.copyWith(
        forgotStatus: ForgotPasswordStateStatus.verified,
        otpOrToken: otp,
        successMessage: 'OTP verified successfully.',
      );
    } catch (e) {
      state = state.copyWith(
        forgotStatus: ForgotPasswordStateStatus.error,
        errorMessage: _msg(e),
      );
    }
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
    String? otpOrToken,
  }) async {
    if (newPassword != confirmPassword) {
      state = state.copyWith(
        resetStatus: ResetPasswordStateStatus.error,
        errorMessage: 'Passwords do not match.',
      );
      return;
    }

    if (!_isStrongPassword(newPassword)) {
      state = state.copyWith(
        resetStatus: ResetPasswordStateStatus.error,
        errorMessage: 'Password must be at least 8 characters with letters and numbers.',
      );
      return;
    }

    final credential = (otpOrToken ?? state.otpOrToken ?? '').trim();
    if (credential.isEmpty) {
      state = state.copyWith(
        resetStatus: ResetPasswordStateStatus.error,
        errorMessage: 'OTP or reset token is required.',
      );
      return;
    }

    state = state.copyWith(
      resetStatus: ResetPasswordStateStatus.loading,
      forgotStatus: ForgotPasswordStateStatus.loading,
      email: email,
      clearError: true,
      clearSuccess: true,
    );

    try {
      await ref.read(resetPasswordUseCaseProvider).call(email, newPassword, credential);
      state = state.copyWith(
        forgotStatus: ForgotPasswordStateStatus.success,
        resetStatus: ResetPasswordStateStatus.success,
        successMessage: 'Password reset successfully. Please login.',
        clearOtpOrToken: true,
      );
    } catch (e) {
      state = state.copyWith(
        forgotStatus: ForgotPasswordStateStatus.error,
        resetStatus: ResetPasswordStateStatus.error,
        errorMessage: _msg(e),
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  String _msg(Object e) => e.toString().replaceAll('Exception: ', '').trim();

  bool _isStrongPassword(String password) {
    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    return regex.hasMatch(password);
  }

  String _readCachedEmail() {
    if (!Hive.isBoxOpen('authBox')) return '';
    final box = Hive.box('authBox');
    return box.get(_resetEmailCacheKey)?.toString() ?? '';
  }

  Future<void> _cacheEmail(String email) async {
    if (!Hive.isBoxOpen('authBox')) {
      try {
        final box = await Hive.openBox('authBox');
        await box.put(_resetEmailCacheKey, email);
      } catch (_) {
        // Non-fatal cache failure.
      }
      return;
    }

    final box = Hive.box('authBox');
    await box.put(_resetEmailCacheKey, email);
  }
}
