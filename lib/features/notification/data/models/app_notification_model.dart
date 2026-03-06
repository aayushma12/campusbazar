import '../../domain/entities/app_notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.referenceId,
    required super.isRead,
    required super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      type: (json['type'] ?? 'system').toString(),
      referenceId: json['referenceId']?.toString(),
      isRead: json['isRead'] == true,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
