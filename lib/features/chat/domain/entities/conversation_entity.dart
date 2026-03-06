import 'package:equatable/equatable.dart';

class Conversation extends Equatable {
  final String id;
  final String chatType;
  final String relatedEntityId;
  final String productId;
  final String productTitle;
  final List<String> participantIds;
  final Map<String, String> participantNamesById;
  final Map<String, String> participantRolesById;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    this.chatType = 'product',
    this.relatedEntityId = '',
    required this.productId,
    required this.productTitle,
    required this.participantIds,
    this.participantNamesById = const {},
    this.participantRolesById = const {},
    required this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        chatType,
        relatedEntityId,
        productId,
        productTitle,
        participantIds,
        participantNamesById,
        participantRolesById,
        lastMessage,
        lastMessageTime,
        unreadCount,
        updatedAt,
      ];
}
