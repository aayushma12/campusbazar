import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_data_source.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource _remoteDataSource;
  ChatRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Conversation>> getConversations() => _remoteDataSource.getConversations();

  @override
  Future<Conversation> startConversation(String productId) => _remoteDataSource.startConversation(productId);

  @override
  Future<Conversation> startTutorConversation(String tutorRequestId) =>
      _remoteDataSource.startTutorConversation(tutorRequestId);

  @override
  Future<List<Message>> getMessages(String conversationId, {DateTime? since}) =>
      _remoteDataSource.getMessages(conversationId, since: since);

  @override
  Future<Message> sendMessage(String conversationId, String message) =>
      _remoteDataSource.sendMessage(conversationId, message);

  @override
  Future<void> markMessagesAsRead(String conversationId) => _remoteDataSource.markMessagesAsRead(conversationId);
}
