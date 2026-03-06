import 'package:flutter/material.dart';

import '../../domain/entities/message_entity.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMine;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleColor = _bubbleColor(message.senderRole, isMine);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    message.senderName.isEmpty ? (isMine ? 'You' : 'User') : message.senderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isMine ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _badgeBg(message.senderRole),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _roleLabel(message.senderRole),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: _badgeFg(message.senderRole),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.messageText,
                style: TextStyle(color: isMine ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _time(message.timestamp ?? message.createdAt),
                  style: TextStyle(fontSize: 10, color: isMine ? Colors.white70 : Colors.black54),
                ),
                if (isMine) ...[
                  const SizedBox(width: 6),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 13,
                    color: message.isRead ? Colors.blue : Colors.black45,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _bubbleColor(String senderRole, bool isMine) {
    switch (senderRole.toLowerCase()) {
      case 'tutor':
        return isMine ? Colors.green.shade800 : Colors.green.shade50;
      case 'student':
        return isMine ? Colors.green.shade500 : Colors.white;
      case 'seller':
        return isMine ? Colors.indigo.shade700 : Colors.indigo.shade50;
      case 'buyer':
        return isMine ? Colors.teal.shade700 : Colors.teal.shade50;
      default:
        return isMine ? Colors.green.shade600 : Colors.grey.shade200;
    }
  }

  String _roleLabel(String senderRole) {
    switch (senderRole.toLowerCase()) {
      case 'tutor':
        return 'Tutor';
      case 'student':
        return 'Student';
      case 'seller':
        return 'Seller';
      case 'buyer':
        return 'Buyer';
      case 'admin':
        return 'Admin';
      default:
        return 'User';
    }
  }

  Color _badgeBg(String senderRole) {
    switch (senderRole.toLowerCase()) {
      case 'tutor':
        return Colors.green.shade100;
      case 'student':
        return Colors.blue.shade100;
      case 'seller':
        return Colors.indigo.shade100;
      case 'buyer':
        return Colors.teal.shade100;
      case 'admin':
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  Color _badgeFg(String senderRole) {
    switch (senderRole.toLowerCase()) {
      case 'tutor':
        return Colors.green.shade800;
      case 'student':
        return Colors.blue.shade800;
      case 'seller':
        return Colors.indigo.shade800;
      case 'buyer':
        return Colors.teal.shade800;
      case 'admin':
        return Colors.purple.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  String _time(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
