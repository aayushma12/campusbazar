import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/app_notification.dart';
import '../providers/notification_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationNotifierProvider.notifier).loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationNotifierProvider);

    ref.listen(notificationNotifierProvider, (previous, next) {
      final message = next.error;
      if (message != null && message.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
        ref.read(notificationNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(notificationNotifierProvider.notifier).markAllAsRead(),
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationNotifierProvider.notifier).loadNotifications(refresh: true),
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.notifications.isEmpty
                ? _EmptyNotificationsView(onRefresh: () {
                    ref.read(notificationNotifierProvider.notifier).loadNotifications(refresh: true);
                  })
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.notifications.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final notification = state.notifications[index];
                      return _NotificationTile(
                        notification: notification,
                        onTap: () async {
                          await ref.read(notificationNotifierProvider.notifier).markAsRead(notification.id);
                          if (!context.mounted) return;
                          _handleNotificationTap(context, notification);
                        },
                      );
                    },
                  ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, AppNotification notification) {
    final refId = notification.referenceId;

    switch (notification.type) {
      case 'new_message':
        if (refId != null && refId.isNotEmpty) {
          Navigator.pushNamed(context, '/chatDetail', arguments: {'conversationId': refId});
          return;
        }
        Navigator.pushNamed(context, '/chats');
        return;
      case 'new_product_uploaded':
      case 'product_sold':
        if (refId != null && refId.isNotEmpty) {
          Navigator.pushNamed(context, '/productDetail', arguments: {'productId': refId});
          return;
        }
        Navigator.pushNamed(context, '/products');
        return;
      case 'tutor_request_accepted':
        Navigator.pushNamed(context, '/tutors');
        return;
      default:
        return;
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = notification.createdAt;
    final formatted = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return ListTile(
      tileColor: notification.isRead ? null : Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_outlined),
          if (!notification.isRead)
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
        ],
      ),
      title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(notification.message),
          const SizedBox(height: 6),
          Text(
            formatted,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _EmptyNotificationsView extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyNotificationsView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_off_outlined, size: 72, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('No notifications yet', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
                  const SizedBox(height: 8),
                  const Text(
                    'When important updates happen, you will see them here.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
