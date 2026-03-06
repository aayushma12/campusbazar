import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';

enum ConversationStatus { initial, loading, loaded, error }
enum MessageStatus { initial, loading, sending, loaded, error }

class ChatState {
  final ConversationStatus conversationStatus;
  final MessageStatus messageStatus;
  final List<Conversation> conversations;
  final List<Message> messages;
  final String? activeConversationId;
  final String? currentUserId;
  final bool polling;
  final bool unauthorized;
  final String? errorMessage;

  const ChatState({
    this.conversationStatus = ConversationStatus.initial,
    this.messageStatus = MessageStatus.initial,
    this.conversations = const [],
    this.messages = const [],
    this.activeConversationId,
    this.currentUserId,
    this.polling = false,
    this.unauthorized = false,
    this.errorMessage,
  });

  ChatState copyWith({
    ConversationStatus? conversationStatus,
    MessageStatus? messageStatus,
    List<Conversation>? conversations,
    List<Message>? messages,
    String? activeConversationId,
    String? currentUserId,
    bool? polling,
    bool? unauthorized,
    String? errorMessage,
    bool clearError = false,
    bool clearMessages = false,
  }) {
    return ChatState(
      conversationStatus: conversationStatus ?? this.conversationStatus,
      messageStatus: messageStatus ?? this.messageStatus,
      conversations: conversations ?? this.conversations,
      messages: clearMessages ? const [] : (messages ?? this.messages),
      activeConversationId: activeConversationId ?? this.activeConversationId,
      currentUserId: currentUserId ?? this.currentUserId,
      polling: polling ?? this.polling,
      unauthorized: unauthorized ?? this.unauthorized,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
