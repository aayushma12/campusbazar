import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations();
  Future<ConversationModel> startConversation(String productId);
  Future<ConversationModel> startTutorConversation(String tutorRequestId);
  Future<List<MessageModel>> getMessages(String conversationId, {DateTime? since});
  Future<MessageModel> sendMessage(String conversationId, String messageText);
  Future<void> markMessagesAsRead(String conversationId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final ApiClient _apiClient;
  ChatRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.chat);
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>? ?? const [];
      return data.whereType<Map<String, dynamic>>().map(ConversationModel.fromJson).toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to load conversations'));
    }
  }

  @override
  Future<ConversationModel> startConversation(String productId) async {
    try {
      final response = await _apiClient.post(ApiEndpoints.chat, data: {'productId': productId});
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? const {};
      return ConversationModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to start conversation'));
    }
  }

  @override
  Future<ConversationModel> startTutorConversation(String tutorRequestId) async {
    try {
      final response = await _apiClient.post('${ApiEndpoints.chat}/tutor/$tutorRequestId');
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? const {};
      return ConversationModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to start tutor chat'));
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId, {DateTime? since}) async {
    try {
      final response = await _apiClient.get(
        '${ApiEndpoints.chat}/$conversationId/messages',
        queryParameters: {
          'page': 1,
          'limit': 50,
          if (since != null) 'since': since.toIso8601String(),
        },
      );
      final body = response.data as Map<String, dynamic>;

      final dynamic raw = body['data'];
      final List<dynamic> list = raw is List
          ? raw
          : (raw is Map<String, dynamic>
              ? (raw['messages'] as List<dynamic>? ?? raw['items'] as List<dynamic>? ?? const [])
              : const []);

      return list
          .whereType<Map<String, dynamic>>()
          .map(MessageModel.fromJson)
          .where((m) => m.id.isNotEmpty || m.messageText.trim().isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to load messages'));
    }
  }

  @override
  Future<MessageModel> sendMessage(String conversationId, String messageText) async {
    try {
      final response = await _apiClient.post(
        '${ApiEndpoints.chat}/$conversationId/messages',
        data: {'text': messageText, 'messageText': messageText},
      );

      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? const {};
      return MessageModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to send message'));
    }
  }

  @override
  Future<void> markMessagesAsRead(String conversationId) async {
    try {
      await _apiClient.patch('${ApiEndpoints.chat}/$conversationId/messages/read');
    } on DioException catch (e) {
      throw Exception(_parseError(e, fallback: 'Failed to mark messages as read'));
    }
  }

  String _parseError(DioException e, {required String fallback}) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final msg = data is Map<String, dynamic> ? data['message']?.toString() : null;

    if (status == 401) return 'Unauthorized. Please login again.';
    if (status == 404) return msg ?? 'Conversation not found.';
    if (status == 500) return msg ?? 'Server error. Please try again.';
    return msg ?? e.message ?? fallback;
  }
}
