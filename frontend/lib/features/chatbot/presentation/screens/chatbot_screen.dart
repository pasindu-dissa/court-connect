<<<<<<< HEAD
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';
=======
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_activity_service.dart';
import '../../../../core/services/api_service.dart';
import '../chat_ui/chat_bubble.dart';
import '../models/chat_session_store.dart';
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
<<<<<<< HEAD
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = const [
    _ChatMessage(
      text:
          'Hi, I am Court Coach. I can help with bookings, player invites, venue questions, and match prep.',
      isUser: false,
      label: 'Court Coach',
      footer: 'Ready to connect to live assistant',
    ),
  ].toList();

  final List<String> _preparedQuestions = const [
    'Can you find an evening badminton court for me?',
    'Can you draft a player invite message?',
    'What should I pack for match day?',
    'Can you help me find doubles players?',
  ];

  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
=======
  final ChatSessionStore _sessionStore = ChatSessionStore.instance;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  final ApiService _apiService = ApiService();
  bool _isSending = false;

  List<_Message> get _messages {
    return _sessionStore.messages
        .map(
          (message) => _Message(
            text: message['text'] as String? ?? '',
            isUser: message['isUser'] as bool? ?? false,
            label: message['label'] as String?,
            footer: message['footer'] as String?,
            isError: message['isError'] as bool? ?? false,
          ),
        )
        .toList();
  }

  List<String> get _quickReplies => _sessionStore.quickReplies;

  @override
  void initState() {
    super.initState();
    AppActivityService.instance.recordScreenView('chat');
    _controller.addListener(_handleComposerChanged);
    _inputFocusNode.addListener(_handleComposerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleComposerChanged);
    _controller.dispose();
    _inputFocusNode.removeListener(_handleComposerChanged);
    _inputFocusNode.dispose();
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
    _scrollController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  Future<void> _sendMessage([String? presetText]) async {
    final text = (presetText ?? _controller.text).trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _messages.add(
        _ChatMessage(
          text: text,
          isUser: true,
        ),
      );
      _controller.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/ai/chat'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': text,
              'history': _messages
                  .where((message) => !message.isError)
                  .map(
                    (message) => {
                      'role': message.isUser ? 'user' : 'assistant',
                      'content': message.text,
                    },
                  )
                  .toList(),
            }),
          )
          .timeout(const Duration(seconds: 25));

      final decoded = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 400) {
        throw Exception(decoded['error'] ?? 'Chat request failed.');
      }

      final reply = decoded['reply'] as String?;
      if (reply == null || reply.trim().isEmpty) {
        throw Exception('Backend returned an empty chatbot response.');
      }
=======
  void _handleComposerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _shouldCollapseIntro {
    return _inputFocusNode.hasFocus ||
        _controller.text.trim().isNotEmpty ||
        _sessionStore.hasOpenedPreparedQuestions;
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = (presetText ?? _controller.text).trim();
    if (text.isEmpty) {
      return;
    }

    final history = _messages
        .where((message) => !message.isError)
        .map(
          (message) => ChatRequestMessage(
            role: message.isUser ? 'user' : 'assistant',
            content: message.text,
          ),
        )
        .toList();

    setState(() {
      _sessionStore.setHasOpenedPreparedQuestions(true);
      _sessionStore.addMessage(
        text: text,
        isUser: true,
      );
      _isSending = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final reply = await _apiService.sendChatMessage(
        message: text,
        history: history,
        activityContext: AppActivityService.instance.buildContextPayload(),
        sessionId: _sessionStore.sessionId,
      );
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f

      if (!mounted) {
        return;
      }

      setState(() {
<<<<<<< HEAD
        _messages.add(
          _ChatMessage(
            text: reply.trim(),
            isUser: false,
            label: decoded['source'] == 'openai'
                ? 'Court Coach AI'
                : 'Court Coach Demo',
          ),
=======
        _sessionStore.setSessionId(reply.sessionId);
        if (reply.quickReplies.isNotEmpty) {
          _sessionStore.setQuickReplies(reply.quickReplies);
        }
        _sessionStore.addMessage(
          text: reply.reply,
          isUser: false,
          label:
              reply.source == 'openai' ? 'Court Coach AI' : 'Court Coach Demo',
        );
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _sessionStore.addMessage(
          text:
              'I could not reach the chatbot backend. ${error.message} Check that the backend is running and that the app is pointing to the correct local port.',
          isUser: false,
          isError: true,
          label: 'Connection issue',
          footer: 'Expected local backend on port 52445',
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
        );
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
<<<<<<< HEAD
        _messages.add(
          const _ChatMessage(
            text:
                'Something unexpected happened while contacting the assistant. Restart the backend and try again.',
            isUser: false,
            label: 'Unexpected error',
            footer: 'Court Coach could not complete this request',
            isError: true,
          ),
=======
        _sessionStore.addMessage(
          text:
              'Something unexpected happened while contacting the assistant. Restart the backend and try again.',
          isUser: false,
          isError: true,
          label: 'Unexpected error',
          footer: 'Court Coach could not complete this request',
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
<<<<<<< HEAD
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
=======
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    });
  }

  Future<void> _showPreparedQuestionsSheet() async {
    if (!_sessionStore.hasOpenedPreparedQuestions && mounted) {
      setState(() {
        _sessionStore.setHasOpenedPreparedQuestions(true);
      });
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final sheetTheme = Theme.of(sheetContext);
        final maxHeight = MediaQuery.of(sheetContext).size.height * 0.72;

        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            decoration: BoxDecoration(
              color: sheetTheme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Prepared questions',
                    style: TextStyle(
                      color: sheetTheme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pick a starter and Court Coach will send it instantly.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ..._quickReplies.map(
                    (quickReply) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _PreparedQuestionTile(
                        label: quickReply,
                        enabled: !_isSending,
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _sendMessage(quickReply);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showIntro = !_shouldCollapseIntro;
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f

    return Scaffold(
      appBar: AppBar(
        title: const Text('Court Coach'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
<<<<<<< HEAD
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFEAF7F0),
                  Color(0xFFDCEFE6),
                  Color(0xFFEFF8F3),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.18),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        child: Icon(
                          Icons.smart_toy_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your in-app sports assistant',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: theme.cardColor.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: ListView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        for (final message in _messages)
                          _ChatBubble(message: message),
                        if (_isSending) const _TypingIndicatorBubble(),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Try one of these prepared questions',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.expand_less_rounded,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _preparedQuestions.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final quickReply = _preparedQuestions[index];
                            return GestureDetector(
                              onTap: _isSending
                                  ? null
                                  : () => _sendMessage(quickReply),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.16),
                                  ),
                                ),
                                child: Text(
                                  quickReply,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            enabled: !_isSending,
                            textInputAction: TextInputAction.send,
                            minLines: 1,
                            maxLines: 4,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: _isSending ? 'Typing...' : 'Message...',
                              filled: true,
                              fillColor: theme.cardColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _isSending ? null : _sendMessage,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _isSending
                                  ? AppColors.primaryLight
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.22),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isSending
                                  ? Icons.more_horiz_rounded
                                  : Icons.send_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
=======
          const Positioned.fill(
            child: _SportsBackground(),
          ),
          Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: showIntro
                    ? Container(
                        key: const ValueKey('chat-intro'),
                        margin: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.primaryDark,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.18),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white24,
                                  child: Icon(
                                    Icons.smart_toy_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Your in-app sports assistant',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ask for booking help, player coordination, or a quick game-day plan without leaving the app.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.88),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _InfoChip(
                                  icon: Icons.bolt_rounded,
                                  label: _isSending ? 'Thinking...' : 'Live replies',
                                ),
                                _InfoChip(
                                  icon: Icons.link_rounded,
                                  label: _sessionStore.sessionId == null
                                      ? 'New session'
                                      : 'Connected',
                                ),
                                const _InfoChip(
                                  icon: Icons.sports_tennis_rounded,
                                  label: 'Booking tips',
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    : const SizedBox(
                        key: ValueKey('chat-intro-hidden'),
                        height: 8,
                      ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardColor.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: ListView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      for (final message in _messages)
                        ChatBubble(
                          text: message.text,
                          isUser: message.isUser,
                          label: message.label,
                          footer: message.footer,
                          isError: message.isError,
                        ),
                      if (_isSending) const _TypingIndicatorBubble(),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.cardColor.withOpacity(0.82),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _isSending ? null : _showPreparedQuestionsSheet,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Try one of these prepared questions',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(
                                    Icons.expand_less_rounded,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 42,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _quickReplies.take(3).length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 10),
                                  itemBuilder: (context, index) {
                                    final quickReply =
                                        _quickReplies.take(3).elementAt(index);
                                    return _QuickReplyButton(
                                      label: quickReply,
                                      enabled: !_isSending,
                                      onTap: () => _sendMessage(quickReply),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _inputFocusNode,
                              enabled: !_isSending,
                              textInputAction: TextInputAction.send,
                              minLines: 1,
                              maxLines: 4,
                              onSubmitted: (_) => _sendMessage(),
                              decoration: InputDecoration(
                                hintText: _isSending ? 'Typing...' : 'Message...',
                                filled: true,
                                fillColor: theme.cardColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(22),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: _isSending ? null : _sendMessage,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _isSending
                                    ? AppColors.primaryLight
                                    : AppColors.primary,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.22),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isSending
                                    ? Icons.more_horiz_rounded
                                    : Icons.send_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
          ),
        ],
      ),
    );
  }
}

<<<<<<< HEAD
class _ChatMessage {
  const _ChatMessage({
=======
class _Message {
  const _Message({
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
    required this.text,
    required this.isUser,
    this.label,
    this.footer,
    this.isError = false,
  });

  final String text;
  final bool isUser;
  final String? label;
  final String? footer;
  final bool isError;
}

<<<<<<< HEAD
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bubbleColor = message.isUser
        ? AppColors.primary
        : message.isError
            ? AppColors.error.withOpacity(0.10)
            : theme.cardColor;
    final textColor =
        message.isUser ? Colors.white : theme.colorScheme.onSurface;
    final labelColor = message.isUser
        ? Colors.white.withOpacity(0.84)
        : message.isError
            ? AppColors.error
            : AppColors.textSecondary;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(message.isUser ? 20 : 8),
              bottomRight: Radius.circular(message.isUser ? 8 : 20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: message.isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.label != null) ...[
                Text(
                  message.label!,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
              ],
              Text(
                message.text,
                style: TextStyle(
                  color: textColor,
                  height: 1.4,
                ),
              ),
              if (message.footer != null) ...[
                const SizedBox(height: 8),
                Text(
                  message.footer!,
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
=======
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickReplyButton extends StatelessWidget {
  const _QuickReplyButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: enabled ? 1 : 0.55,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.16),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _PreparedQuestionTile extends StatelessWidget {
  const _PreparedQuestionTile({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.12),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingIndicatorBubble extends StatefulWidget {
  const _TypingIndicatorBubble();

  @override
  State<_TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<_TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Court Coach is typing',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  children: List.generate(3, (index) {
                    final phase = (_controller.value - (index * 0.2)).clamp(
                      0.0,
                      1.0,
                    );
                    final opacity = 0.25 + (phase * 0.75);

                    return Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(opacity),
                        shape: BoxShape.circle,
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
<<<<<<< HEAD
=======

class _SportsBackground extends StatefulWidget {
  const _SportsBackground();

  @override
  State<_SportsBackground> createState() => _SportsBackgroundState();
}

class _SportsBackgroundState extends State<_SportsBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final drift = (_controller.value - 0.5) * 18;
        final stripeShift = _controller.value * 24;

        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? const [
                          Color(0xFF0A2A24),
                          Color(0xFF0A241F),
                          Color(0xFF081B18),
                        ]
                      : const [
                          Color(0xFFEAF7F0),
                          Color(0xFFDCEFE6),
                          Color(0xFFEFF8F3),
                        ],
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _FootballFieldPainter(
                  stripeShift: stripeShift,
                  lineColor: Colors.white.withOpacity(isDark ? 0.08 : 0.14),
                  stripeColorA: AppColors.primary.withOpacity(
                    isDark ? 0.10 : 0.07,
                  ),
                  stripeColorB: AppColors.primaryDark.withOpacity(
                    isDark ? 0.12 : 0.05,
                  ),
                ),
              ),
            ),
            _FloatingSportIcon(
              top: 110 + drift,
              left: 26,
              icon: Icons.sports_cricket_rounded,
              size: 30,
              angle: -0.18,
              color: Colors.white.withOpacity(isDark ? 0.12 : 0.18),
            ),
            _FloatingSportIcon(
              top: 168 - (drift * 0.5),
              right: 32,
              icon: Icons.sports_basketball_rounded,
              size: 32,
              angle: 0.22,
              color: Colors.white.withOpacity(isDark ? 0.11 : 0.16),
            ),
            _FloatingSportIcon(
              top: 250 + (drift * 0.3),
              left: 72,
              icon: Icons.sports_tennis_rounded,
              size: 28,
              angle: 0.12,
              color: Colors.white.withOpacity(isDark ? 0.10 : 0.15),
            ),
            _FloatingSportIcon(
              top: 320 - (drift * 0.6),
              right: 88,
              icon: Icons.sports_football_rounded,
              size: 30,
              angle: -0.30,
              color: Colors.white.withOpacity(isDark ? 0.12 : 0.18),
            ),
            _FloatingSportIcon(
              bottom: 236 + (drift * 0.4),
              left: 24,
              icon: Icons.sports_soccer_rounded,
              size: 28,
              angle: 0.18,
              color: Colors.white.withOpacity(isDark ? 0.10 : 0.15),
            ),
            _FloatingSportIcon(
              bottom: 188 - (drift * 0.3),
              right: 38,
              icon: Icons.sports_cricket_rounded,
              size: 26,
              angle: 0.34,
              color: Colors.white.withOpacity(isDark ? 0.09 : 0.14),
            ),
            _FloatingSportIcon(
              bottom: 118 + (drift * 0.2),
              left: 92,
              icon: Icons.sports_tennis_rounded,
              size: 24,
              angle: -0.18,
              color: Colors.white.withOpacity(isDark ? 0.08 : 0.13),
            ),
            _FloatingSportIcon(
              bottom: 94 - (drift * 0.45),
              right: 108,
              icon: Icons.sports_basketball_rounded,
              size: 26,
              angle: 0.14,
              color: Colors.white.withOpacity(isDark ? 0.08 : 0.13),
            ),
          ],
        );
      },
    );
  }
}

class _FloatingSportIcon extends StatelessWidget {
  const _FloatingSportIcon({
    required this.icon,
    required this.size,
    required this.angle,
    required this.color,
    this.top,
    this.right,
    this.bottom,
    this.left,
  });

  final IconData icon;
  final double size;
  final double angle;
  final Color color;
  final double? top;
  final double? right;
  final double? bottom;
  final double? left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: angle,
          child: Icon(
            icon,
            size: size,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _FootballFieldPainter extends CustomPainter {
  const _FootballFieldPainter({
    required this.stripeShift,
    required this.lineColor,
    required this.stripeColorA,
    required this.stripeColorB,
  });

  final double stripeShift;
  final Color lineColor;
  final Color stripeColorA;
  final Color stripeColorB;

  @override
  void paint(Canvas canvas, Size size) {
    final stripePaintA = Paint()..color = stripeColorA;
    final stripePaintB = Paint()..color = stripeColorB;
    const stripeHeight = 56.0;

    for (double y = -stripeHeight; y < size.height + stripeHeight; y += stripeHeight) {
      final rect = Rect.fromLTWH(
        0,
        y + (stripeShift % stripeHeight),
        size.width,
        stripeHeight,
      );
      canvas.drawRect(
        rect,
        (((y / stripeHeight).round()) % 2 == 0) ? stripePaintA : stripePaintB,
      );
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final inset = 18.0;
    final field = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        32,
        size.width - (inset * 2),
        size.height - 96,
      ),
      const Radius.circular(18),
    );

    canvas.drawRRect(field, linePaint);

    final centerX = size.width / 2;
    final top = 32.0;
    final bottom = size.height - 64.0;
    canvas.drawLine(Offset(centerX, top), Offset(centerX, bottom), linePaint);

    final centerCircleRadius = size.width * 0.12;
    canvas.drawCircle(
      Offset(centerX, (top + bottom) / 2),
      centerCircleRadius,
      linePaint,
    );

    final penaltyWidth = size.width * 0.22;
    final penaltyHeight = size.height * 0.14;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, top),
          width: penaltyWidth,
          height: penaltyHeight,
        ),
        const Radius.circular(10),
      ),
      linePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, bottom),
          width: penaltyWidth,
          height: penaltyHeight,
        ),
        const Radius.circular(10),
      ),
      linePaint,
    );

    final goalWidth = size.width * 0.10;
    final goalHeight = size.height * 0.05;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, top),
          width: goalWidth,
          height: goalHeight,
        ),
        const Radius.circular(8),
      ),
      linePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, bottom),
          width: goalWidth,
          height: goalHeight,
        ),
        const Radius.circular(8),
      ),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FootballFieldPainter oldDelegate) {
    return oldDelegate.stripeShift != stripeShift ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.stripeColorA != stripeColorA ||
        oldDelegate.stripeColorB != stripeColorB;
  }
}
>>>>>>> 57585150f2f1c98b8b02485b0cd0afe96ded3d9f
