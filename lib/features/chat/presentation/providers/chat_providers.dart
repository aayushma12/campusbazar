import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

import '../../../../core/api/api_client.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import '../../data/datasources/chat_socket_data_source.dart';
import '../../data/models/message_model.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/mark_messages_read_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import '../../domain/usecases/start_conversation_usecase.dart';
import '../../domain/usecases/start_tutor_conversation_usecase.dart';
import 'chat_state.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ChatRemoteDataSourceImpl(GetIt.instance<ApiClient>()));
});

final chatSocketDataSourceProvider = Provider<ChatSocketDataSource>((ref) {
  final socketDataSource = ChatSocketDataSource();
  ref.onDispose(socketDataSource.dispose);
  return socketDataSource;
});

final getConversationsUseCaseProvider = Provider<GetConversationsUseCase>((ref) {
  return GetConversationsUseCase(ref.read(chatRepositoryProvider));
});

final startConversationUseCaseProvider = Provider<StartConversationUseCase>((ref) {
  return StartConversationUseCase(ref.read(chatRepositoryProvider));
});

final startTutorConversationUseCaseProvider = Provider<StartTutorConversationUseCase>((ref) {
  return StartTutorConversationUseCase(ref.read(chatRepositoryProvider));
});

final getMessagesUseCaseProvider = Provider<GetMessagesUseCase>((ref) {
  return GetMessagesUseCase(ref.read(chatRepositoryProvider));
});

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(ref.read(chatRepositoryProvider));
});

final markMessagesReadUseCaseProvider = Provider<MarkMessagesReadUseCase>((ref) {
  return MarkMessagesReadUseCase(ref.read(chatRepositoryProvider));
});

final chatNotifierProvider = AutoDisposeNotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

// Backward-compatible alias for old imports.
final chatViewModelProvider = chatNotifierProvider;

class ChatNotifier extends AutoDisposeNotifier<ChatState> {
  Timer? _pollingTimer;
  StreamSubscription<Map<String, dynamic>>? _socketSubscription;
  bool _isDisposed = false;
  bool _pollingBusy = false;
  int _pollingGeneration = 0;

  @override
  ChatState build() {
    ref.onDispose(() {
      _isDisposed = true;
      _stopPollingInternal();
      _socketSubscription?.cancel();
      ref.read(chatSocketDataSourceProvider).disconnect();
    });
    return const ChatState();
  }

  Future<void> loadConversations() async {
    await _ensureCurrentUserId();

    _safeSetState((s) => s.copyWith(
          conversationStatus: ConversationStatus.loading,
          clearError: true,
          unauthorized: false,
        ));

    try {
      final conversations = await ref.read(getConversationsUseCaseProvider).call();
      _safeSetState((s) => s.copyWith(
            conversationStatus: ConversationStatus.loaded,
            conversations: conversations,
          ));
    } catch (e) {
      _safeSetState((s) => s.copyWith(
            conversationStatus: ConversationStatus.error,
            errorMessage: _msg(e),
            unauthorized: _isUnauthorized(e),
          ));
    }
  }

  Future<Conversation?> startConversation(String productId) async {
    await _ensureCurrentUserId();

    try {
      final conversation = await ref.read(startConversationUseCaseProvider).call(productId);
      final list = List<Conversation>.from(state.conversations);
      final index = list.indexWhere((e) => e.id == conversation.id);
      if (index >= 0) {
        list[index] = conversation;
      } else {
        list.insert(0, conversation);
      }
      _safeSetState((s) => s.copyWith(
            conversations: list,
            conversationStatus: ConversationStatus.loaded,
          ));
      return conversation;
    } catch (e) {
      _safeSetState((s) => s.copyWith(
            conversationStatus: ConversationStatus.error,
            errorMessage: _msg(e),
            unauthorized: _isUnauthorized(e),
          ));
      return null;
    }
  }

  Future<Conversation?> startTutorConversation(String tutorRequestId) async {
    await _ensureCurrentUserId();

    try {
      final conversation = await ref.read(startTutorConversationUseCaseProvider).call(tutorRequestId);
      final list = List<Conversation>.from(state.conversations);
      final index = list.indexWhere((e) => e.id == conversation.id);
      if (index >= 0) {
        list[index] = conversation;
      } else {
        list.insert(0, conversation);
      }
      _safeSetState((s) => s.copyWith(
            conversations: list,
            conversationStatus: ConversationStatus.loaded,
          ));
      return conversation;
    } catch (e) {
      _safeSetState((s) => s.copyWith(
            conversationStatus: ConversationStatus.error,
            errorMessage: _msg(e),
            unauthorized: _isUnauthorized(e),
          ));
      return null;
    }
  }

  Future<String?> openConversation({String? conversationId, String? productId, String? tutorRequestId}) async {
    await _ensureCurrentUserId();

    String? resolvedConversationId = conversationId;

    if (resolvedConversationId == null || resolvedConversationId.isEmpty) {
      if (productId != null && productId.isNotEmpty) {
        final conversation = await startConversation(productId);
        resolvedConversationId = conversation?.id;
      } else if (tutorRequestId != null && tutorRequestId.isNotEmpty) {
        final conversation = await startTutorConversation(tutorRequestId);
        resolvedConversationId = conversation?.id;
      } else {
        _safeSetState(
          (s) => s.copyWith(errorMessage: 'Conversation, product, or tutor request identifier is required.'),
        );
        return null;
      }
    }

    if (resolvedConversationId == null || resolvedConversationId.isEmpty) {
      return null;
    }

    _safeSetState((s) => s.copyWith(activeConversationId: resolvedConversationId, clearError: true));

    await _connectRealtime(resolvedConversationId);
    await loadMessages(resolvedConversationId);
    await markMessagesAsRead(resolvedConversationId);

    return resolvedConversationId;
  }

  Future<void> _connectRealtime(String conversationId) async {
    try {
      final token = await GetIt.instance<ApiClient>().getAuthToken();
      if (token == null || token.isEmpty) return;

      final socketDataSource = ref.read(chatSocketDataSourceProvider);
      await socketDataSource.connect(token);
      socketDataSource.joinConversation(conversationId);

      _socketSubscription ??= socketDataSource.messages.listen((payload) async {
        final incoming = MessageModel.fromJson(payload);
        if (incoming.id.isEmpty || incoming.conversationId.isEmpty) return;

        final exists = state.messages.any((m) => m.id == incoming.id);
        if (!exists && incoming.conversationId == state.activeConversationId) {
          final merged = [...state.messages, incoming]
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          _safeSetState((s) => s.copyWith(
                messageStatus: MessageStatus.loaded,
                messages: merged,
              ));

          await markMessagesAsRead(incoming.conversationId);
        }

        await loadConversations();
      });
    } catch (_) {
      // Socket setup is best-effort; REST polling remains as fallback.
    }
  }

  Future<void> loadMessages(String conversationId, {bool silent = false, bool onlyNew = false}) async {
    await _ensureCurrentUserId();

    if (!silent) {
      _safeSetState((s) => s.copyWith(
            messageStatus: MessageStatus.loading,
            clearError: true,
            unauthorized: false,
          ));
    }

    try {
      DateTime? since;
      if (onlyNew && state.messages.isNotEmpty) {
        since = state.messages.last.createdAt;
      }

      final incoming = await ref.read(getMessagesUseCaseProvider).call(conversationId, since: since);

      final mergedMap = <String, Message>{
        for (final m in state.messages) m.id: m,
      };
      for (final m in incoming) {
        mergedMap[m.id] = m;
      }

      final merged = mergedMap.values.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      _safeSetState((s) => s.copyWith(
            messageStatus: MessageStatus.loaded,
            messages: merged,
            activeConversationId: conversationId,
          ));
    } catch (e) {
      _safeSetState((s) => s.copyWith(
            messageStatus: MessageStatus.error,
            errorMessage: _msg(e),
            unauthorized: _isUnauthorized(e),
          ));
    }
  }

  Future<void> sendMessageOptimistic(String conversationId, String messageText) async {
    if (messageText.trim().isEmpty) return;

    await _ensureCurrentUserId();
    final currentUserId = state.currentUserId ?? '';

    final conversation = state.conversations.firstWhere(
      (c) => c.id == conversationId,
      orElse: () => Conversation(
        id: conversationId,
        productId: '',
        productTitle: 'Conversation',
        participantIds: const [],
        lastMessage: '',
        unreadCount: 0,
        updatedAt: DateTime.now(),
      ),
    );

    final receiverId = conversation.participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    final optimistic = Message(
      id: 'tmp-${DateTime.now().microsecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: currentUserId,
      receiverId: receiverId,
      senderName: 'You',
      senderRole: conversation.participantRolesById[currentUserId] ?? 'unknown',
      chatType: conversation.chatType,
      messageText: messageText,
      messageType: 'text',
      isRead: false,
      timestamp: DateTime.now(),
      createdAt: DateTime.now(),
    );

    final previous = List<Message>.from(state.messages);
    final optimisticList = [...state.messages, optimistic]..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    _safeSetState((s) => s.copyWith(
          messageStatus: MessageStatus.sending,
          messages: optimisticList,
          clearError: true,
        ));

    try {
      final serverMessage = await ref.read(sendMessageUseCaseProvider).call(conversationId, messageText);

      final replaced = List<Message>.from(state.messages)
          .map((m) => m.id == optimistic.id ? serverMessage : m)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      _safeSetState((s) => s.copyWith(messages: replaced, messageStatus: MessageStatus.loaded));

      await loadMessages(conversationId, silent: true, onlyNew: false);
      await loadConversations();
    } catch (e) {
      _safeSetState((s) => s.copyWith(
            messageStatus: MessageStatus.error,
            messages: previous,
            errorMessage: _msg(e),
            unauthorized: _isUnauthorized(e),
          ));
    }
  }

  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await ref.read(markMessagesReadUseCaseProvider).call(conversationId);

      final updatedConversations = state.conversations
          .map((c) => c.id == conversationId
              ? Conversation(
                  id: c.id,
              chatType: c.chatType,
              relatedEntityId: c.relatedEntityId,
                  productId: c.productId,
                  productTitle: c.productTitle,
                  participantIds: c.participantIds,
              participantNamesById: c.participantNamesById,
              participantRolesById: c.participantRolesById,
                  lastMessage: c.lastMessage,
                  lastMessageTime: c.lastMessageTime,
                  unreadCount: 0,
                  updatedAt: c.updatedAt,
                )
              : c)
          .toList();

      final currentUserId = state.currentUserId ?? '';
      final updatedMessages = state.messages
          .map((m) => m.senderId != currentUserId ? m.copyWith(isRead: true) : m)
          .toList();

      _safeSetState((s) => s.copyWith(conversations: updatedConversations, messages: updatedMessages));
    } catch (_) {
      // Ignore non-critical mark-as-read failures.
    }
  }

  void startPolling(String conversationId) {
    _stopPollingInternal();
    final generation = ++_pollingGeneration;

    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      if (!_canMutateState || generation != _pollingGeneration || _pollingBusy) return;
      _pollingBusy = true;
      try {
        await loadMessages(conversationId, silent: true, onlyNew: true);
        if (!_canMutateState || generation != _pollingGeneration) return;

        await markMessagesAsRead(conversationId);
        if (!_canMutateState || generation != _pollingGeneration) return;
      } finally {
        _pollingBusy = false;
      }
    });
  }

  void stopPolling() {
    _stopPollingInternal();
  }

  void clearError() {
    _safeSetState((s) => s.copyWith(clearError: true, unauthorized: false));
  }

  Future<void> _ensureCurrentUserId() async {
    if (state.currentUserId != null && state.currentUserId!.isNotEmpty) return;

    final id = await _resolveCurrentUserId();
    if (id != null && id.isNotEmpty) {
      _safeSetState((s) => s.copyWith(currentUserId: id));
    }
  }

  Future<String?> _resolveCurrentUserId() async {
    try {
      if (Hive.isBoxOpen('authenticationBox')) {
        final box = Hive.box('authenticationBox');
        final user = box.get('AUTH_USER');
        final id = (user as dynamic).id?.toString();
        if (id != null && id.isNotEmpty) return id;
      }
    } catch (_) {}

    try {
      if (Hive.isBoxOpen('authBox')) {
        final box = Hive.box('authBox');
        final user = box.get('CACHED_USER');
        final id = (user as dynamic).id?.toString();
        if (id != null && id.isNotEmpty) return id;
      }
    } catch (_) {}

    return null;
  }

  bool _isUnauthorized(Object e) {
    final lower = _msg(e).toLowerCase();
    return lower.contains('401') || lower.contains('unauthorized');
  }

  String _msg(Object e) => e.toString().replaceAll('Exception: ', '').trim();

  bool get _canMutateState => !_isDisposed;

  void _safeSetState(ChatState Function(ChatState current) updater) {
    if (!_canMutateState) return;
    state = updater(state);
  }

  void _stopPollingInternal() {
    _pollingGeneration++;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _pollingBusy = false;
  }
}
