import 'auth_user_model.dart';

/// Backend login response shape (from /api/v1/auth/login):
/// {
///   "user": {...},
///   "accessToken": "...",
///   "refreshToken": "..."
/// }
class LoginResponseModel {
  final AuthUserModel user;
  final String accessToken;
  final String refreshToken;

  const LoginResponseModel({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final userJson = (json['user'] as Map<String, dynamic>? ?? <String, dynamic>{});

    return LoginResponseModel(
      user: AuthUserModel.fromBackendJson(userJson),
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
    );
  }
}

/// Backend register response shape (from /api/v1/auth/register):
/// {
///   "message": "Registration successful..."
/// }
class RegisterResponseModel {
  final String message;

  const RegisterResponseModel({required this.message});

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      message: (json['message'] ?? 'Registration successful').toString(),
    );
  }
}

/// Common backend error shape used in auth endpoints:
/// {
///   "success": false,
///   "message": "Error details"
/// }
class AuthApiErrorModel {
  final bool success;
  final String message;

  const AuthApiErrorModel({required this.success, required this.message});

  factory AuthApiErrorModel.fromJson(Map<String, dynamic> json) {
    return AuthApiErrorModel(
      success: (json['success'] ?? false) as bool,
      message: (json['message'] ?? 'Unexpected server error').toString(),
    );
  }
}
