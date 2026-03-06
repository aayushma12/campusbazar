import '../repositories/chat_repository.dart';

class MarkMessagesReadUseCase {
  final ChatRepository repository;

  MarkMessagesReadUseCase(this.repository);

  Future<void> call(String conversationId) {
    return repository.markMessagesAsRead(conversationId);
  }
}
