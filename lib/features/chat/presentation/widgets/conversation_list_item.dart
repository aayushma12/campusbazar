import 'package:flutter/material.dart';

import '../../domain/entities/conversation_entity.dart';

class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.green.shade50,
        child: const Icon(Icons.storefront, color: Colors.green),
      ),
      title: Text(
        conversation.productTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2, bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: conversation.chatType == 'tutor' ? Colors.green.shade50 : Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              conversation.chatType == 'tutor' ? 'Tutor Session Chat' : 'Product Inquiry Chat',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: conversation.chatType == 'tutor' ? Colors.green.shade800 : Colors.indigo.shade800,
              ),
            ),
          ),
          Text(
            conversation.lastMessage.isEmpty ? 'Start chatting in this conversation' : conversation.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            _formatTime(conversation.lastMessageTime ?? conversation.updatedAt),
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          if (conversation.unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${conversation.unreadCount}',
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${dateTime.month}/${dateTime.day}';
  }
}
