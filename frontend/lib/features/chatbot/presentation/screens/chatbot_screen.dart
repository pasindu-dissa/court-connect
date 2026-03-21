import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_colors.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = const [
    _ChatMessage(
      text: 'Hi, I am Court Coach. I can help with bookings, player invites, venue questions, and match prep.',
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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = (presetText ?? _controller.text).trim();
    if (text.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
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

      if (!mounted) return;

      setState(() {
        _messages.add(
          _ChatMessage(
            text: reply.trim(),
            isUser: false,
            label: decoded['source'] == 'openai' ? 'Court Coach AI' : 'Court Coach',
          ),
        );
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _messages.add(
          const _ChatMessage(
            text: 'Something unexpected happened while contacting the assistant. Restart the app and try again.',
            isUser: false,
            label: 'Network Error',
            footer: 'Court Coach could not complete this request',
            isError: true,
          ),
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
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Court Coach', style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w600, fontSize: 16)),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- Beautiful Header Card ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF00E676)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your in-app assistant',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ask me anything about sports, venues, or rules!',
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- Chat Messages Area ---
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                physics: const BouncingScrollPhysics(),
                itemCount: _messages.length + (_isSending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isSending) {
                    return const _TypingIndicatorBubble();
                  }
                  return _ChatBubble(message: _messages[index]);
                },
              ),
            ),

            // --- Quick Replies & Input Area ---
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Replies
                  if (_messages.length < 3) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Suggestions',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _preparedQuestions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final quickReply = _preparedQuestions[index];
                          return GestureDetector(
                            onTap: _isSending ? null : () => _sendMessage(quickReply),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(isDark ? 0.4 : 0.2),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                quickReply,
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Modern Input Bar
                  Padding(
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
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: _isSending ? 'Thinking...' : 'Message Court Coach...',
                              hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                              filled: true,
                              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _isSending ? null : _sendMessage,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isSending 
                                  ? [Colors.grey.shade400, Colors.grey.shade500] 
                                  : [AppColors.primary, const Color(0xFF00E676)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: _isSending ? [] : [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Models & Widgets ---

class _ChatMessage {
  const _ChatMessage({
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

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final bubbleColor = message.isUser
        ? AppColors.primary
        : message.isError
            ? AppColors.error.withOpacity(isDark ? 0.2 : 0.1)
            : (isDark ? theme.cardColor : Colors.white);
            
    final textColor = message.isUser 
        ? Colors.white 
        : (isDark ? Colors.white : Colors.black87);
        
    final labelColor = message.isUser
        ? Colors.white.withOpacity(0.8)
        : message.isError
            ? AppColors.error
            : AppColors.primary;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(message.isUser ? 20 : 4),
              bottomRight: Radius.circular(message.isUser ? 4 : 20),
            ),
            boxShadow: [
              if (!message.isUser && !isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
            border: isDark && !message.isUser ? Border.all(color: Colors.white10) : null,
          ),
          child: Column(
            crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (message.label != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!message.isUser && !message.isError) ...[
                      Icon(Icons.smart_toy_rounded, size: 14, color: labelColor),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      message.label!,
                      style: TextStyle(
                        color: labelColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              Text(
                message.text,
                style: TextStyle(
                  color: textColor, 
                  height: 1.4,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (message.footer != null) ...[
                const SizedBox(height: 10),
                Text(
                  message.footer!,
                  style: TextStyle(
                    color: message.isUser ? Colors.white70 : Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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

class _TypingIndicatorBubbleState extends State<_TypingIndicatorBubble> with SingleTickerProviderStateMixin {
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
    final isDark = theme.brightness == Brightness.dark;
    
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? theme.cardColor : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
          border: isDark ? Border.all(color: Colors.white10) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return Row(
                  children: List.generate(3, (index) {
                    final phase = (_controller.value - (index * 0.2)).clamp(0.0, 1.0);
                    final opacity = 0.25 + (phase * 0.75);
                    return Container(
                      width: 6,
                      height: 6,
                      margin: EdgeInsets.only(right: index == 2 ? 0 : 4),
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