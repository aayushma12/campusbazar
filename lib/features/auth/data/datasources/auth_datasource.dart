import '../models/auth_response_model.dart';

abstract class IAuthDataSource {
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<bool> logout();
}
