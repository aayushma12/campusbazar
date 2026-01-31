import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import '../api/api_endpoints.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return GetIt.instance<ApiClient>();
});

class ApiClient {
  final Dio _dio;
  final AuthLocalDataSource authLocalDataSource;

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
        final token = await authLocalDataSource.getToken();
        if (token != null) {
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
      _dio.get(path, queryParameters: queryParameters);

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      _dio.post(path, data: data, queryParameters: queryParameters);

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      _dio.put(path, data: data, queryParameters: queryParameters);

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      _dio.patch(path, data: data, queryParameters: queryParameters);

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) =>
      _dio.delete(path, data: data, queryParameters: queryParameters);
}
