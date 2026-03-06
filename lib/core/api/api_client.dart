import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:get_it/get_it.dart';
import '../api/api_endpoints.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return GetIt.instance<ApiClient>();
});

class ApiClient {
  final Dio _dio;
  final AuthLocalDataSource authLocalDataSource;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiClient({required Dio dio, required this.authLocalDataSource}) : _dio = dio {
    _dio.options.baseUrl = ApiEndpoints.baseUrl;
    _dio.options.connectTimeout = ApiEndpoints.connectionTimeout;
    _dio.options.receiveTimeout = ApiEndpoints.receiveTimeout;
    
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Auth Interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _resolveAuthToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    // Logger Interceptor
    if (kDebugMode) {
      _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ));
    }
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) =>
      _requestWithFallback(
        method: 'GET',
        path: path,
        queryParameters: queryParameters,
      );

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      _requestWithFallback(
        method: 'POST',
        path: path,
        data: data,
        queryParameters: queryParameters,
      );

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      _requestWithFallback(
        method: 'PUT',
        path: path,
        data: data,
        queryParameters: queryParameters,
      );

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      _requestWithFallback(
        method: 'PATCH',
        path: path,
        data: data,
        queryParameters: queryParameters,
      );

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      _requestWithFallback(
        method: 'DELETE',
        path: path,
        data: data,
        queryParameters: queryParameters,
      );

  Future<String?> getAuthToken() => _resolveAuthToken();

  Future<Response<dynamic>> _requestWithFallback({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final originalBaseUrl = _dio.options.baseUrl;

    try {
      return await _dio.request(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );
    } on DioException catch (firstError) {
      if (!_isConnectivityError(firstError)) {
        rethrow;
      }

      for (final candidate in ApiEndpoints.fallbackBaseUrls) {
        if (candidate == _dio.options.baseUrl) continue;

        try {
          _dio.options.baseUrl = candidate;
          final response = await _dio.request(
            path,
            data: data,
            queryParameters: queryParameters,
            options: Options(method: method),
          );
          return response;
        } on DioException catch (retryError) {
          if (!_isConnectivityError(retryError)) {
            rethrow;
          }
        }
      }

      _dio.options.baseUrl = originalBaseUrl;
      rethrow;
    }
  }

  bool _isConnectivityError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.unknown;
  }

  /// Resolve token from both legacy and new auth storage implementations.
  Future<String?> _resolveAuthToken() async {
    // 1) Legacy auth module storage.
    final legacyToken = await authLocalDataSource.getToken();
    if (legacyToken != null && legacyToken.isNotEmpty) {
      return legacyToken;
    }

    // 2) New authentication module secure storage.
    final secureToken = await _secureStorage.read(key: 'secure_access_token');
    if (secureToken != null && secureToken.isNotEmpty) {
      return secureToken;
    }

    // 3) Fallback to new authentication Hive box, if available.
    if (Hive.isBoxOpen('authenticationBox')) {
      final authBox = Hive.box('authenticationBox');
      final hiveToken = authBox.get('ACCESS_TOKEN')?.toString();
      if (hiveToken != null && hiveToken.isNotEmpty) {
        return hiveToken;
      }
    }

    return null;
  }
}
