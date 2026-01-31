import '../models/auth_user_model.dart';

abstract class IAuthDataSource {
  Future<AuthUserModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthUserModel> login({
    required String email,
    required String password,
  });

  Future<bool> logout();
}
