import '../../domain/entities/message_entity.dart';

class MessageModel extends Message {
  const MessageModel({
    required String id,
    required String conversationId,
    required String senderId,
    required String receiverId,
    String senderName = 'User',
    String senderRole = 'unknown',
    String chatType = 'product',
    required String messageText,
    String messageType = 'text',
    required bool isRead,
    DateTime? timestamp,
    required DateTime createdAt,
  }) : super(
          id: id,
          conversationId: conversationId,
          senderId: senderId,
          receiverId: receiverId,
          senderName: senderName,
          senderRole: senderRole,
          chatType: chatType,
          messageText: messageText,
          messageType: messageType,
          isRead: isRead,
          timestamp: timestamp,
          createdAt: createdAt,
        );

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    final senderId = _extractId(json['senderId'] ?? json['sender']);
    final receiverId = _extractId(json['receiverId'] ?? json['receiver']);
    final text = (
      json['text'] ??
      json['messageText'] ??
      json['message'] ??
      json['content'] ??
      ''
    ).toString();

    return MessageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      conversationId: _extractId(json['conversationId']),
      senderId: senderId,
      receiverId: receiverId,
      senderName: (json['senderName'] ?? 'User').toString(),
      senderRole: (json['senderRole'] ?? 'unknown').toString(),
      chatType: _normalizeChatType(json['chatType'] ?? json['contextType']),
      messageText: text,
      messageType: (json['messageType'] ?? json['type'] ?? 'text').toString(),
      isRead: json['read'] == true || json['isRead'] == true,
      timestamp: DateTime.tryParse((json['timestamp'] ?? '').toString()),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }

  factory MessageModel.optimistic({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String messageText,
  }) {
    final now = DateTime.now();
    return MessageModel(
      id: 'tmp-${now.microsecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      senderName: 'You',
      senderRole: 'unknown',
      chatType: 'product',
      messageText: messageText,
      messageType: 'text',
      isRead: false,
      timestamp: now,
      createdAt: now,
    );
  }

  static String _normalizeChatType(dynamic value) {
    final raw = (value ?? '').toString().toLowerCase();
    if (raw == 'tutor' || raw == 'tutor_request') return 'tutor';
    return 'product';
  }

  static String _extractId(dynamic value) {
    if (value is Map<String, dynamic>) {
      return (value['_id'] ?? value['id'] ?? '').toString();
    }
    if (value is Map) {
      return (value['_id'] ?? value['id'] ?? '').toString();
    }
    return value?.toString() ?? '';
  }
}
