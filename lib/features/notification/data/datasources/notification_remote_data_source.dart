import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/app_notification_model.dart';

class NotificationListResponse {
  final List<AppNotificationModel> notifications;
  final int unreadCount;

  const NotificationListResponse({
    required this.notifications,
    required this.unreadCount,
  });
}

abstract class NotificationRemoteDataSource {
  Future<NotificationListResponse> getNotifications({int page = 1, int limit = 30});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<NotificationListResponse> getNotifications({int page = 1, int limit = 30}) async {
    try {
      final response = await _apiClient.get(
        ApiEndpoints.notifications,
        queryParameters: {'page': page, 'limit': limit},
      );

      final raw = response.data as Map<String, dynamic>;
      final data = raw['data'] as Map<String, dynamic>? ?? const {};
      final list = data['notifications'] as List<dynamic>? ?? const [];

      return NotificationListResponse(
        notifications: list
            .whereType<Map<String, dynamic>>()
            .map(AppNotificationModel.fromJson)
            .toList(growable: false),
        unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
      );
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to load notifications'));
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.notificationsUnreadCount);
      final raw = response.data as Map<String, dynamic>;
      final data = raw['data'] as Map<String, dynamic>? ?? const {};
      return (data['unreadCount'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to load unread count'));
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _apiClient.patch('${ApiEndpoints.notifications}/$id/read');
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to mark notification as read'));
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.patch('${ApiEndpoints.notifications}/read-all');
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to mark all notifications as read'));
    }
  }

  String _parseError(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
    }
    return e.message ?? fallback;
  }
}
