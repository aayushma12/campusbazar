import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/auth_request_model.dart';
import '../models/auth_user_model.dart';
import 'auth_datasource.dart';

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuthRemoteDatasource(apiClient: apiClient);
});

class AuthRemoteDatasource implements IAuthDataSource {
  final ApiClient _apiClient;

  AuthRemoteDatasource({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<AuthUserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final request = AuthRequestModel(name: name, email: email, password: password);
//try
    try {
      final response = await _apiClient.post(ApiEndpoints.register, data: request.toJson());
      return AuthUserModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Registration failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('An unexpected error occurred during registration');
    }
  }

  @override
  Future<AuthUserModel> login({
    required String email,
    required String password,
  }) async {
    final request = AuthRequestModel(name: '', email: email, password: password);

    try {
      final response = await _apiClient.post(ApiEndpoints.login, data: request.toJson());
      return AuthUserModel.fromJson(response.data);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Login failed';
      throw Exception(message);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<bool> logout() async {
    // Local storage clearing is handled by repository or logout usecase
    return true;
  }
}
