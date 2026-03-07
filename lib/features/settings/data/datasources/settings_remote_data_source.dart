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
      return SettingsData(
        pushNotificationsEnabled: _extractPushNotificationsEnabled(response.data),
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      // Backward compatibility: some backend versions do not expose
      // /users/me/settings yet. In that case, fallback to profile endpoint and
      // avoid blocking the Settings page.
      if (statusCode == 404) {
        try {
          final profileResponse = await _apiClient.get(ApiEndpoints.profile);
          return SettingsData(
            pushNotificationsEnabled: _extractPushNotificationsEnabled(profileResponse.data),
          );
        } on DioException {
          // If even profile payload doesn't provide this info, keep a safe default
          // and let the page render without a hard error.
          return const SettingsData(pushNotificationsEnabled: true);
        }
      }

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

  bool _extractPushNotificationsEnabled(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      return true;
    }

    final data = raw['data'];
    final dataMap = data is Map<String, dynamic> ? data : const <String, dynamic>{};

    final candidates = <dynamic>[
      raw['pushNotificationsEnabled'],
      raw['pushNotificationEnabled'],
      raw['notificationsEnabled'],
      raw['notificationEnabled'],
      dataMap['pushNotificationsEnabled'],
      dataMap['pushNotificationEnabled'],
      dataMap['notificationsEnabled'],
      dataMap['notificationEnabled'],
    ];

    for (final value in candidates) {
      if (value is bool) return value;
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        if (normalized == 'true') return true;
        if (normalized == 'false') return false;
      }
      if (value is num) {
        return value != 0;
      }
    }

    return true;
  }
}
