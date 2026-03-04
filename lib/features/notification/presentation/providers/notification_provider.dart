import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/datasources/notification_remote_data_source.dart';
import '../../domain/entities/app_notification.dart';

class NotificationState {
  final bool isLoading;
  final bool isRefreshing;
  final List<AppNotification> notifications;
  final int unreadCount;
  final String? error;

  const NotificationState({
    this.isLoading = false,
    this.isRefreshing = false,
    this.notifications = const [],
    this.unreadCount = 0,
    this.error,
  });

  NotificationState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    List<AppNotification>? notifications,
    int? unreadCount,
    String? error,
    bool clearError = false,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final notificationDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSourceImpl(sl<ApiClient>());
});

final notificationNotifierProvider = NotifierProvider<NotificationNotifier, NotificationState>(
  NotificationNotifier.new,
);

final unreadNotificationCountProvider = Provider<int>((ref) {
  return ref.watch(notificationNotifierProvider).unreadCount;
});

class NotificationNotifier extends Notifier<NotificationState> {
  late final NotificationRemoteDataSource _dataSource;

  @override
  NotificationState build() {
    _dataSource = ref.read(notificationDataSourceProvider);
    return const NotificationState();
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    state = state.copyWith(
      isLoading: !refresh,
      isRefreshing: refresh,
      clearError: true,
    );

    try {
      final result = await _dataSource.getNotifications();
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        notifications: result.notifications,
        unreadCount: result.unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> refreshUnreadCount() async {
    try {
      final unreadCount = await _dataSource.getUnreadCount();
      state = state.copyWith(unreadCount: unreadCount);
    } catch (_) {
      // non-blocking
    }
  }

  Future<void> markAsRead(String id) async {
    AppNotification? target;
    for (final item in state.notifications) {
      if (item.id == id) {
        target = item;
        break;
      }
    }
    if (target == null || target.isRead) return;

    state = state.copyWith(
      notifications: state.notifications
          .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
          .toList(growable: false),
      unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
    );

    try {
      await _dataSource.markAsRead(id);
    } catch (_) {
      await loadNotifications(refresh: true);
    }
  }

  Future<void> markAllAsRead() async {
    final hasUnread = state.notifications.any((n) => !n.isRead);
    if (!hasUnread) return;

    final previous = state;
    state = state.copyWith(
      notifications: state.notifications.map((n) => n.copyWith(isRead: true)).toList(growable: false),
      unreadCount: 0,
    );

    try {
      await _dataSource.markAllAsRead();
    } catch (_) {
      state = previous;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
