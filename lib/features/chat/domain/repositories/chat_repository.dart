import '../entities/conversation_entity.dart';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Future<List<Conversation>> getConversations();
  Future<Conversation> startConversation(String productId);
  Future<Conversation> startTutorConversation(String tutorRequestId);
  Future<List<Message>> getMessages(String conversationId, {DateTime? since});
  Future<Message> sendMessage(String conversationId, String message);
  Future<void> markMessagesAsRead(String conversationId);
}
