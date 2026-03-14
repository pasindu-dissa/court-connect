import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiService {
  ApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.backendBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<ChatReplyPayload> sendChatMessage({
    required String message,
    required List<ChatRequestMessage> history,
    String? sessionId,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/ai/chat');

    final response = await _client
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': message,
            'sessionId': sessionId,
            'history': history.map((item) => item.toJson()).toList(),
          }),
        )
        .timeout(const Duration(seconds: 25));

    final decoded = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 400) {
      throw ApiException(
        decoded['error'] as String? ??
            'AI request failed with status ${response.statusCode}.',
      );
    }

    final reply = decoded['reply'] as String?;
    final nextSessionId = decoded['sessionId'] as String?;

    if (reply == null || reply.trim().isEmpty) {
      throw const ApiException('Backend returned an empty chatbot response.');
    }

    if (nextSessionId == null || nextSessionId.trim().isEmpty) {
      throw const ApiException('Backend did not return a session ID.');
    }

    return ChatReplyPayload(
      reply: reply.trim(),
      sessionId: nextSessionId,
      source: decoded['source'] as String? ?? 'unknown',
      model: decoded['model'] as String? ?? 'unknown',
      responseId: decoded['responseId'] as String?,
      quickReplies: ((decoded['quickReplies'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
      timestamp: decoded['timestamp'] as String?,
    );
  }
}

class ChatRequestMessage {
  const ChatRequestMessage({
    required this.role,
    required this.content,
  });

  final String role;
  final String content;

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class ChatReplyPayload {
  const ChatReplyPayload({
    required this.reply,
    required this.sessionId,
    required this.source,
    required this.model,
    required this.responseId,
    required this.quickReplies,
    required this.timestamp,
  });

  final String reply;
  final String sessionId;
  final String source;
  final String model;
  final String? responseId;
  final List<String> quickReplies;
  final String? timestamp;
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
