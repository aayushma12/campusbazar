import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_providers.dart';
import '../providers/chat_state.dart';
import '../widgets/conversation_list_item.dart';

class ConversationsPage extends ConsumerStatefulWidget {
  const ConversationsPage({super.key});

  @override
  ConsumerState<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends ConsumerState<ConversationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).loadConversations();
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
    });

    final state = ref.watch(chatNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
            }
          },
        ),
        title: const Text('Chats', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(chatNotifierProvider.notifier).loadConversations(),
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(ChatState state) {
    if (state.conversationStatus == ConversationStatus.loading && state.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.conversations.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 110),
          Icon(Icons.chat_bubble_outline, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Center(
            child: Text('No conversations yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 6),
          const Center(child: Text('Start by chatting with a seller from a product page.')),
        ],
      );
    }

    return ListView.separated(
      itemCount: state.conversations.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
      itemBuilder: (context, index) {
        final c = state.conversations[index];
        return ConversationListItem(
          conversation: c,
          onTap: () => Navigator.pushNamed(
            context,
            '/chatDetail',
            arguments: {'conversationId': c.id},
          ),
        );
      },
    );
  }
}
