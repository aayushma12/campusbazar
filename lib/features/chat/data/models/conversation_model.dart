import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends Conversation {
  const ConversationModel({
    required String id,
    String chatType = 'product',
    String relatedEntityId = '',
    required String productId,
    required String productTitle,
    required List<String> participantIds,
    Map<String, String> participantNamesById = const {},
    Map<String, String> participantRolesById = const {},
    required String lastMessage,
    DateTime? lastMessageTime,
    required int unreadCount,
    required DateTime updatedAt,
  }) : super(
          id: id,
          chatType: chatType,
          relatedEntityId: relatedEntityId,
          productId: productId,
          productTitle: productTitle,
          participantIds: participantIds,
          participantNamesById: participantNamesById,
          participantRolesById: participantRolesById,
          lastMessage: lastMessage,
          lastMessageTime: lastMessageTime,
          unreadCount: unreadCount,
          updatedAt: updatedAt,
        );

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final participants = json['participants'] as List<dynamic>? ?? const [];
    final participantNamesById = <String, String>{};
    final participantRolesById = <String, String>{};

    for (final raw in participants) {
      if (raw is! Map) continue;
      final item = raw.cast<String, dynamic>();
      final id = (item['id'] ?? item['_id'] ?? '').toString();
      if (id.isEmpty) continue;
      participantNamesById[id] = (item['name'] ?? 'User').toString();
      participantRolesById[id] = (item['role'] ?? 'unknown').toString();
    }

    final participantIds = participants
        .whereType<Map<String, dynamic>>()
        .map((e) => (e['id'] ?? e['_id'] ?? '').toString())
        .where((e) => e.isNotEmpty)
        .toList();

    final buyerId = _idToString(json['buyerId']);
    final sellerId = _idToString(json['sellerId']);

    final product = json['productId'] is Map<String, dynamic> ? json['productId'] as Map<String, dynamic> : const {};
    final productId = (product['_id'] ?? product['id'] ?? json['productId'] ?? '').toString();
    final tutorRequest = json['tutorRequest'] is Map<String, dynamic> ? json['tutorRequest'] as Map<String, dynamic> : const {};
    final tutorRequestId = (tutorRequest['id'] ?? tutorRequest['_id'] ?? '').toString();

    final chatType = _normalizeChatType(json['chatType'] ?? json['contextType']);
    final relatedEntityId = (json['relatedEntityId'] ?? (chatType == 'tutor' ? tutorRequestId : productId)).toString();

    final contextTitle = chatType == 'tutor'
        ? (tutorRequest['subject'] ?? tutorRequest['topic'] ?? 'Tutor Session Chat').toString()
        : (product['title'] ?? 'Product conversation').toString();

    final updatedAt = DateTime.tryParse((json['updatedAt'] ?? '').toString()) ?? DateTime.now();

    return ConversationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      chatType: chatType,
      relatedEntityId: relatedEntityId,
      productId: productId,
      productTitle: contextTitle,
      participantIds: participantIds.isNotEmpty
          ? participantIds
          : [
              if (buyerId.isNotEmpty) buyerId,
              if (sellerId.isNotEmpty) sellerId,
            ],
      participantNamesById: participantNamesById,
      participantRolesById: participantRolesById,
      lastMessage: (json['lastMessage'] ?? '').toString(),
      lastMessageTime: updatedAt,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      updatedAt: updatedAt,
    );
  }

  static String _normalizeChatType(dynamic value) {
    final raw = (value ?? '').toString().toLowerCase();
    if (raw == 'tutor' || raw == 'tutor_request') return 'tutor';
    return 'product';
  }

  static String _idToString(dynamic value) {
    if (value is Map<String, dynamic>) {
      return (value['_id'] ?? value['id'] ?? '').toString();
    }
    return value?.toString() ?? '';
  }
}
