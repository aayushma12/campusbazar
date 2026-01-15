import 'package:campus_bazar/core/api/api_client.dart';
import 'package:campus_bazar/core/api/api_endpoints.dart';
import 'package:campus_bazar/features/auth/data/datasources/auth_datasource.dart';
import 'package:campus_bazar/features/auth/data/models/auth_request_model.dart';
import 'package:campus_bazar/features/auth/data/models/auth_response_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRemoteDatasource(apiClient: apiClient);
});

class AuthRemoteDatasource implements IAuthDataSource {
  final ApiClient _apiClient;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final request = AuthRequestModel(name: name, email: email, password: password);

    try {
      final response = await _apiClient.post(ApiEndpoints.register, data: request.toJson());
      final authResponse = AuthResponseModel.fromJson(response.data);

      await _saveUserData(authResponse);
      await _secureStorage.write(key: 'access_token', value: authResponse.token);

      return authResponse;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final request = AuthRequestModel(name: '', email: email, password: password);

    try {
      final response = await _apiClient.post(ApiEndpoints.login, data: request.toJson());
      final authResponse = AuthResponseModel.fromJson(response.data);

      await _saveUserData(authResponse);
      await _secureStorage.write(key: 'access_token', value: authResponse.token);

      return authResponse;
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveUserData(AuthResponseModel user) async {
    await _secureStorage.write(key: 'user_id', value: user.userId);
    await _secureStorage.write(key: 'user_name', value: user.name);
    await _secureStorage.write(key: 'user_email', value: user.email);
  }
}
