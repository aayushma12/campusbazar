import '../../domain/entities/password_reset_request.dart';

class PasswordResetRequestModel extends PasswordResetRequest {
  const PasswordResetRequestModel({
    required super.email,
    super.otp,
    super.token,
    super.newPassword,
    super.confirmPassword,
  });

  factory PasswordResetRequestModel.fromEntity(PasswordResetRequest entity) {
    return PasswordResetRequestModel(
      email: entity.email,
      otp: entity.otp,
      token: entity.token,
      newPassword: entity.newPassword,
      confirmPassword: entity.confirmPassword,
    );
  }

  Map<String, dynamic> toForgotJson() => {'email': email};

  Map<String, dynamic> toVerifyJson() => {
        'email': email,
        'otp': otp,
      };

  Map<String, dynamic> toResetJson() => {
        'email': email,
        'newPassword': newPassword,
        'otpOrToken': otpOrToken,
      };
}
