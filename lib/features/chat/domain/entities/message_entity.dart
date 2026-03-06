import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String senderRole;
  final String chatType;
  final String messageText;
  final String messageType;
  final bool isRead;
  final DateTime? timestamp;
  final DateTime createdAt;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    this.senderName = 'User',
    this.senderRole = 'unknown',
    this.chatType = 'product',
    required this.messageText,
    this.messageType = 'text',
    required this.isRead,
    this.timestamp,
    required this.createdAt,
  });

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? receiverId,
    String? senderName,
    String? senderRole,
    String? chatType,
    String? messageText,
    String? messageType,
    bool? isRead,
    DateTime? timestamp,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole ?? this.senderRole,
      chatType: chatType ?? this.chatType,
      messageText: messageText ?? this.messageText,
      messageType: messageType ?? this.messageType,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        conversationId,
        senderId,
        receiverId,
        senderName,
        senderRole,
        chatType,
        messageText,
        messageType,
        isRead,
        timestamp,
        createdAt,
      ];
}
