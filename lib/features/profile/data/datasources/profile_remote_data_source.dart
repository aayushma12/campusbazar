import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_client.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  /// GET /api/v1/users/me
  Future<ProfileModel> getProfile();

  /// PATCH /api/v1/users/me (multipart/form-data)
  /// Supports text fields + optional `profilePicture` file upload.
  Future<ProfileModel> updateProfile(Map<String, dynamic> body, File? imageFile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
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
        if (value != null && value.toString().trim().isNotEmpty) {
          sanitized[key] = value;
        }
      });

      final formData = FormData.fromMap(sanitized);

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'profilePicture',
          await MultipartFile.fromFile(imageFile.path),
        ));
      }

      final response = await _apiClient.patch(ApiEndpoints.profile, data: formData);
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

  String _extractApiErrorMessage(DioException error, {required String fallback}) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    return error.message ?? fallback;
  }
}
