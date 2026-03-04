import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_providers.dart';
import '../providers/chat_state.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  String? _conversationId;
  String? _productId;
  String? _tutorRequestId;
  bool _bootstrapped = false;
  int _lastMessageCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _conversationId = args['conversationId']?.toString();
      _productId = args['productId']?.toString();
      _tutorRequestId = args['tutorRequestId']?.toString();
    } else if (args is String) {
      _conversationId = args;
    }

    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName != null && routeName.contains('?')) {
      final uri = Uri.tryParse(routeName);
      _conversationId = uri?.queryParameters['conversationId'] ?? _conversationId;
      _productId = uri?.queryParameters['productId'] ?? _productId;
      _tutorRequestId = uri?.queryParameters['tutorRequestId'] ?? _tutorRequestId;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final resolvedId = await ref.read(chatNotifierProvider.notifier).openConversation(
            conversationId: _conversationId,
            productId: _productId,
            tutorRequestId: _tutorRequestId,
          );
      if (!mounted || resolvedId == null) return;
      _conversationId = resolvedId;
      ref.read(chatNotifierProvider.notifier).startPolling(resolvedId);
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ChatState>(chatNotifierProvider, (previous, next) {
      if (!mounted) return;

      if (next.unauthorized) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
        ref.read(chatNotifierProvider.notifier).clearError();
      }

      if (next.messages.length != _lastMessageCount) {
        _lastMessageCount = next.messages.length;
        _scrollToBottom();
      }
    });

    final state = ref.watch(chatNotifierProvider);
    dynamic activeConversation;
    for (final conversation in state.conversations) {
      if (conversation.id == _conversationId) {
        activeConversation = conversation;
        break;
      }
    }
    final activeChatType = (activeConversation?.chatType ?? 'product').toString();
    final contextLabel = activeChatType == 'tutor' ? 'Tutor Session Chat' : 'Product Inquiry Chat';

    if ((_conversationId == null || _conversationId!.isEmpty) &&
        (_productId == null || _productId!.isEmpty) &&
        (_tutorRequestId == null || _tutorRequestId!.isEmpty)) {
      return const Scaffold(body: Center(child: Text('No chat selected')));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/chats', (route) => false);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chat', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
              decoration: BoxDecoration(
                color: activeChatType == 'tutor' ? Colors.green.shade50 : Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                contextLabel,
                style: TextStyle(
                  color: activeChatType == 'tutor' ? Colors.green.shade800 : Colors.indigo.shade800,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessages(state),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: state.messageStatus == MessageStatus.sending || _conversationId == null
                      ? null
                      : () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      ref.read(chatNotifierProvider.notifier).sendMessageOptimistic(_conversationId!, text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages(ChatState state) {
    if (state.messageStatus == MessageStatus.loading && state.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.messageStatus == MessageStatus.error && state.messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(18.0),
          child: Text('Unable to load messages. Please try again.'),
        ),
      );
    }

    if (state.messages.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(18.0),
          child: Text('No messages yet. Start the conversation 👋'),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final msg = state.messages[index];
        final isMine = msg.senderId == (state.currentUserId ?? '');
        return MessageBubble(message: msg, isMine: isMine);
      },
    );
  }

  @override
  void dispose() {
    ref.read(chatNotifierProvider.notifier).stopPolling();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }
}
