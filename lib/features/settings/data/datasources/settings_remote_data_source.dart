import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';

class SettingsData {
  final bool pushNotificationsEnabled;

  const SettingsData({required this.pushNotificationsEnabled});
}

abstract class SettingsRemoteDataSource {
  Future<SettingsData> getSettings();
  Future<SettingsData> updatePushNotifications(bool enabled, {String? fcmToken});
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  });
  Future<void> deleteAccount({required String password});
}

class SettingsRemoteDataSourceImpl implements SettingsRemoteDataSource {
  final ApiClient _apiClient;

  SettingsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<SettingsData> getSettings() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.profileSettings);
      final data = response.data as Map<String, dynamic>;
      return SettingsData(
        pushNotificationsEnabled: data['pushNotificationsEnabled'] == true,
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to load settings'));
    }
  }

  @override
  Future<SettingsData> updatePushNotifications(bool enabled, {String? fcmToken}) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.profilePushSettings,
        data: {
          'enabled': enabled,
          if (fcmToken != null && fcmToken.isNotEmpty) 'fcmToken': fcmToken,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return SettingsData(
        pushNotificationsEnabled: data['pushNotificationsEnabled'] == true,
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to update push notification preference'));
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiClient.post(
        ApiEndpoints.profileChangePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to change password'));
    }
  }

  @override
  Future<void> deleteAccount({required String password}) async {
    try {
      await _apiClient.delete(
        ApiEndpoints.profileDeleteAccount,
        data: {'password': password},
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to delete account'));
    }
  }

  String _parseError(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final msg = data['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return e.message ?? fallback;
  }
}
