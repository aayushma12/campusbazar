import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

class StartTutorConversationUseCase {
  final ChatRepository repository;

  StartTutorConversationUseCase(this.repository);

  Future<Conversation> call(String tutorRequestId) {
    return repository.startTutorConversation(tutorRequestId);
  }
}
