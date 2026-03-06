import 'package:dio/dio.dart';

import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_endpoints.dart';

abstract class PasswordResetRemoteDataSource {
  Future<void> requestPasswordReset(String email);
  Future<void> verifyOTP(String email, String otp);
  Future<void> resetPassword(String email, String newPassword, String otpOrToken);
}

class PasswordResetRemoteDataSourceImpl implements PasswordResetRemoteDataSource {
  final ApiClient _apiClient;

  PasswordResetRemoteDataSourceImpl(this._apiClient);

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await _apiClient.post(ApiEndpoints.forgotPassword, data: {'email': email});
    } on DioException catch (e) {
      throw Exception(_errorMessage(e, fallback: 'Failed to request password reset'));
    }
  }

  @override
  Future<void> verifyOTP(String email, String otp) async {
    try {
      await _apiClient.post(ApiEndpoints.verifyOtp, data: {'email': email, 'otp': otp});
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Backward-compatible fallback when backend does not support OTP route.
        return;
      }
      throw Exception(_errorMessage(e, fallback: 'Failed to verify OTP'));
    }
  }

  @override
  Future<void> resetPassword(String email, String newPassword, String otpOrToken) async {
    try {
      await _apiClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'newPassword': newPassword,
          'otpOrToken': otpOrToken,
        },
      );
      return;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Legacy fallback: /reset-password/:token with { password }
        try {
          await _apiClient.post(
            '${ApiEndpoints.resetPassword}/$otpOrToken',
            data: {'password': newPassword},
          );
          return;
        } on DioException catch (fallbackError) {
          throw Exception(_errorMessage(fallbackError, fallback: 'Failed to reset password'));
        }
      }
      throw Exception(_errorMessage(e, fallback: 'Failed to reset password'));
    }
  }

  String _errorMessage(DioException e, {required String fallback}) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final msg = data is Map<String, dynamic> ? data['message']?.toString() : null;

    if (status == 400) return msg ?? 'Invalid request. Please check your input.';
    if (status == 401) return msg ?? 'Invalid or expired OTP/token.';
    if (status == 404) return msg ?? 'User not found.';
    if (status == 500) return msg ?? 'Server error. Please try again.';

    return msg ?? e.message ?? fallback;
  }
}
