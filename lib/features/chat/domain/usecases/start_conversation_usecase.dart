import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

class StartConversationUseCase {
  final ChatRepository repository;

  StartConversationUseCase(this.repository);

  Future<Conversation> call(String productId) {
    return repository.startConversation(productId);
  }
}
