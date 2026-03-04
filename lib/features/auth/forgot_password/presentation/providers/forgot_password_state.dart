enum ForgotPasswordStateStatus { initial, loading, otpSent, verified, success, error }
enum ResetPasswordStateStatus { initial, loading, success, error }

class ForgotPasswordState {
  final ForgotPasswordStateStatus forgotStatus;
  final ResetPasswordStateStatus resetStatus;
  final String email;
  final String? otpOrToken;
  final String? successMessage;
  final String? errorMessage;

  const ForgotPasswordState({
    this.forgotStatus = ForgotPasswordStateStatus.initial,
    this.resetStatus = ResetPasswordStateStatus.initial,
    this.email = '',
    this.otpOrToken,
    this.successMessage,
    this.errorMessage,
  });

  bool get isLoading => forgotStatus == ForgotPasswordStateStatus.loading || resetStatus == ResetPasswordStateStatus.loading;

  ForgotPasswordState copyWith({
    ForgotPasswordStateStatus? forgotStatus,
    ResetPasswordStateStatus? resetStatus,
    String? email,
    String? otpOrToken,
    String? successMessage,
    String? errorMessage,
    bool clearSuccess = false,
    bool clearError = false,
    bool clearOtpOrToken = false,
  }) {
    return ForgotPasswordState(
      forgotStatus: forgotStatus ?? this.forgotStatus,
      resetStatus: resetStatus ?? this.resetStatus,
      email: email ?? this.email,
      otpOrToken: clearOtpOrToken ? null : (otpOrToken ?? this.otpOrToken),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
