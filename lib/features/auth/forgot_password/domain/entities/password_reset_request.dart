import 'package:equatable/equatable.dart';

class PasswordResetRequest extends Equatable {
  final String email;
  final String? otp;
  final String? token;
  final String newPassword;
  final String confirmPassword;

  const PasswordResetRequest({
    required this.email,
    this.otp,
    this.token,
    this.newPassword = '',
    this.confirmPassword = '',
  });

  String get otpOrToken => (otp != null && otp!.isNotEmpty) ? otp! : (token ?? '');

  @override
  List<Object?> get props => [email, otp, token, newPassword, confirmPassword];
}
