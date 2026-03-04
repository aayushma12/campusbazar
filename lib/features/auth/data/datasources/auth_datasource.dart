import '../models/auth_user_model.dart';

abstract class IAuthDataSource {
  Future<AuthUserModel> register({
    required String name,
    required String email,
    required String password,
    String? university,
    String? campus,
  });

  Future<AuthUserModel> login({
    required String email,
    required String password,
  });

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String password,
  });

  Future<bool> logout();
}
