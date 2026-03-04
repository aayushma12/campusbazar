import 'package:dio/dio.dart';

import '../../../../core/api/api_endpoints.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  Future<RegisterResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String university,
    required String campus,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _postWithFallback(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final body = response.data as Map<String, dynamic>;
      return LoginResponseModel.fromJson(body);
    } on DioException catch (e) {
      throw Exception(_extractApiErrorMessage(e));
    } catch (_) {
      throw Exception('Login failed. Please try again.');
    }
  }

  @override
  Future<RegisterResponseModel> register({
    required String name,
    required String email,
    required String password,
    required String university,
    required String campus,
  }) async {
    try {
      final response = await _postWithFallback(
        ApiEndpoints.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'university': university,
          'campus': campus,
        },
      );

      final body = response.data as Map<String, dynamic>;
      return RegisterResponseModel.fromJson(body);
    } on DioException catch (e) {
      throw Exception(_extractApiErrorMessage(e));
    } catch (_) {
      throw Exception('Registration failed. Please try again.');
    }
  }

  String _extractApiErrorMessage(DioException exception) {
    final data = exception.response?.data;

    if (data is Map<String, dynamic>) {
      return (data['message'] ?? 'Request failed').toString();
    }

    return exception.message ?? 'Network request failed';
  }

  Future<Response<dynamic>> _postWithFallback(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final originalBaseUrl = dio.options.baseUrl;

    try {
      return await dio.post(path, data: data);
    } on DioException catch (firstError) {
      if (!_isConnectivityError(firstError)) {
        rethrow;
      }

      for (final candidate in ApiEndpoints.fallbackBaseUrls) {
        if (candidate == dio.options.baseUrl) continue;

        try {
          dio.options.baseUrl = candidate;
          return await dio.post(path, data: data);
        } on DioException catch (retryError) {
          if (!_isConnectivityError(retryError)) {
            rethrow;
          }
        }
      }

      dio.options.baseUrl = originalBaseUrl;
      rethrow;
    }
  }

  bool _isConnectivityError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.unknown;
  }
}
