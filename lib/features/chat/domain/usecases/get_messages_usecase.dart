import '../entities/message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase(this.repository);

  Future<List<Message>> call(String conversationId, {DateTime? since}) {
    return repository.getMessages(conversationId, since: since);
  }
}
