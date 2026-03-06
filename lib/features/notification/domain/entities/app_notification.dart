import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String message;
  final String type;
  final String? referenceId;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? referenceId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, message, type, referenceId, isRead, createdAt];
}
