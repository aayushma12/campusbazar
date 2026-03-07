import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_client.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  /// GET /api/v1/profile
  Future<ProfileModel> getProfile();

  /// PATCH /api/v1/profile (multipart/form-data)
  /// Supports text fields + optional `profilePicture` file upload.
  Future<ProfileModel> updateProfile(Map<String, dynamic> body, File? imageFile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      Response? response;
      DioException? lastRecoverableError;

      final endpoints = <String>[
        ApiEndpoints.profile,
        ApiEndpoints.profileLegacy,
        ApiEndpoints.profileUserMe,
        ApiEndpoints.profileUserLegacy,
      ];

      for (final endpoint in endpoints) {
        try {
          response = await _apiClient.get(endpoint);
          break;
        } on DioException catch (e) {
          if (!_shouldRetryWithLegacyProfile(e)) rethrow;
          lastRecoverableError = e;
        }
      }

      if (response == null) {
        if (lastRecoverableError != null) throw lastRecoverableError;
        throw Exception('Failed to load profile due to unsupported API contract');
      }

      final raw = response.data;

      if (raw is Map<String, dynamic>) {
        return ProfileModel.fromJson(raw);
      }

      throw Exception('Invalid profile response format');
    } on DioException catch (e) {
      final message = _extractApiErrorMessage(e, fallback: 'Failed to load profile');
      throw Exception(message);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<ProfileModel> updateProfile(Map<String, dynamic> body, File? imageFile) async {
    try {
      final sanitized = <String, dynamic>{};
      body.forEach((key, value) {
        if (value != null) {
          sanitized[key] = value is String ? value.trim() : value;
        }
      });

      DioException? lastRecoverableError;
      Response<dynamic>? response;

      final endpoints = <String>[
        ApiEndpoints.profile,
        ApiEndpoints.profileUpdate,
        ApiEndpoints.profileLegacy,
        ApiEndpoints.profileLegacyUpdate,
        ApiEndpoints.profileUserMe,
        ApiEndpoints.profileUserLegacy,
      ];

      for (final endpoint in endpoints) {
        final attempts = <({String method, bool multipart})>[
          (method: 'PATCH', multipart: true),
          (method: 'PUT', multipart: true),
        ];

        for (final attempt in attempts) {
          try {
            response = await _sendUpdateRequest(
              endpoint: endpoint,
              method: attempt.method,
              body: sanitized,
              imageFile: imageFile,
              asMultipart: attempt.multipart,
            );
            break;
          } on DioException catch (e) {
            if (!_isRecoverableUpdateCompatibilityError(e)) {
              rethrow;
            }
            lastRecoverableError = e;
          }
        }

        if (response != null) break;
      }

      if (response == null) {
        if (lastRecoverableError != null) throw lastRecoverableError;
        throw Exception('Failed to update profile due to unsupported API contract');
      }

      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        return ProfileModel.fromJson(raw);
      }

      throw Exception('Invalid update profile response format');
    } on DioException catch (e) {
      final message = _extractApiErrorMessage(e, fallback: 'Failed to update profile');
      throw Exception(message);
    } catch (e) {
      throw Exception('An unexpected error occurred during profile update: ${e.toString()}');
    }
  }

  Future<FormData> _buildFormData(Map<String, dynamic> sanitized, File? imageFile) async {
    final formData = FormData.fromMap(sanitized);

    if (imageFile != null) {
      formData.files.add(MapEntry(
        'profilePicture',
        await MultipartFile.fromFile(imageFile.path),
      ));
    }

    return formData;
  }

  Future<Response<dynamic>> _sendUpdateRequest({
    required String endpoint,
    required String method,
    required Map<String, dynamic> body,
    required File? imageFile,
    required bool asMultipart,
  }) async {
    final data = asMultipart ? await _buildFormData(body, imageFile) : body;

    if (method == 'PATCH') {
      return _apiClient.patch(endpoint, data: data);
    }

    return _apiClient.put(endpoint, data: data);
  }

  bool _shouldRetryWithLegacyProfile(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 404) return true;

    final lower = _extractRawLowercaseError(error);
    return lower.contains('not found') || lower.contains('cannot get');
  }

  bool _isRecoverableUpdateCompatibilityError(DioException error) {
    final statusCode = error.response?.statusCode;
    if (statusCode == 404 || statusCode == 405 || statusCode == 415 || statusCode == 400 || statusCode == 422) {
      return true;
    }

    final lower = _extractRawLowercaseError(error);
    return lower.contains('cannot patch') ||
        lower.contains('cannot put') ||
        lower.contains('method not allowed') ||
        lower.contains('unsupported media type') ||
        lower.contains('invalid content-type') ||
        lower.contains('validation failed') ||
        lower.contains('invalid payload') ||
        lower.contains('not found');
  }

  String _extractRawLowercaseError(DioException error) {
    final buffer = StringBuffer();

    final data = error.response?.data;
    if (data is String) {
      buffer.write(data);
    } else if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null) buffer.write(message);
      final errorField = data['error']?.toString();
      if (errorField != null) {
        if (buffer.isNotEmpty) buffer.write(' ');
        buffer.write(errorField);
      }
    }

    if (error.message != null && error.message!.isNotEmpty) {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(error.message!);
    }

    return buffer.toString().toLowerCase();
  }

  String _extractApiErrorMessage(DioException error, {required String fallback}) {
    final data = error.response?.data;
    if (data is String) {
      final lower = data.toLowerCase();
      if (lower.contains('cannot patch') ||
          lower.contains('cannot put') ||
          lower.contains('not found')) {
        return 'Profile update endpoint not found on server. Please verify backend profile route support.';
      }

      final cleaned = data.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();
      if (cleaned.isNotEmpty) return cleaned;
    }

    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    return error.message ?? fallback;
  }
}
