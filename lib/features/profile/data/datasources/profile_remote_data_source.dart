import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_client.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<ProfileModel> updateProfile(Map<String, dynamic> body, File? imageFile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profile);
      return ProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to load profile';
      throw Exception(message);
    } catch (e) {
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Future<ProfileModel> updateProfile(Map<String, dynamic> body, File? imageFile) async {
    try {
      FormData formData = FormData.fromMap(body);

      if (imageFile != null) {
        formData.files.add(MapEntry(
          'profilePicture',
          await MultipartFile.fromFile(imageFile.path),
        ));
      }

      final response = await _apiClient.patch(ApiEndpoints.profile, data: formData);
      return ProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? e.message ?? 'Failed to update profile';
      throw Exception(message);
    } catch (e) {
      throw Exception('An unexpected error occurred during profile update');
    }
  }
}
