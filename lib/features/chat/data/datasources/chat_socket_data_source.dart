import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../../../core/api/api_endpoints.dart';

class ChatSocketDataSource {
  io.Socket? _socket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  Future<void> connect(String token) async {
    if (_socket != null && _socket!.connected) return;

    final baseUrl = _socketBaseUrl(ApiEndpoints.baseUrl);

    final socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    socket.on('newMessage', (data) {
      if (data is Map) {
        _messageController.add(Map<String, dynamic>.from(data));
      }
    });

    socket.onConnectError((_) {
      // Keep silent; app can continue with REST fallback.
    });

    socket.connect();
    _socket = socket;
  }

  void joinConversation(String conversationId) {
    _socket?.emit('joinConversation', conversationId);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }

  String _socketBaseUrl(String apiBaseUrl) {
    return apiBaseUrl.replaceAll(RegExp(r'/api/v\d+$', caseSensitive: false), '');
  }
}
