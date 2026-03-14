import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/api_service.dart';
import '../chat_ui/chat_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  final ApiService _apiService = ApiService();
  final List<_Message> _messages = const [
    _Message(
      text:
          'Hi, I am Court Coach. I can help with bookings, player invites, venue questions, and match prep.',
      isUser: false,
      label: 'Court Coach',
      footer: 'Ready to connect to live assistant',
    ),
  ].toList();
  List<String> _quickReplies = const [
    'Can you find an evening badminton court for me?',
    'Can you draft a player invite message?',
    'What should I pack for match day?',
  ];
  String? _sessionId;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleComposerChanged);
    _inputFocusNode.addListener(_handleComposerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleComposerChanged);
    _controller.dispose();
    _inputFocusNode.removeListener(_handleComposerChanged);
    _inputFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleComposerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _shouldCollapseIntro {
    return _inputFocusNode.hasFocus || _controller.text.trim().isNotEmpty;
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
      _messages.add(
        _Message(
          text: text,
          isUser: true,
        ),
      );
      _isSending = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final reply = await _apiService.sendChatMessage(
        message: text,
        history: history,
        sessionId: _sessionId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _sessionId = reply.sessionId;
        if (reply.quickReplies.isNotEmpty) {
          _quickReplies = reply.quickReplies;
        }
        _messages.add(
          _Message(
            text: reply.reply,
            isUser: false,
            label:
                reply.source == 'openai' ? 'Court Coach AI' : 'Court Coach Demo',
          ),
        );
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          _Message(
            text:
                'I could not reach the chatbot backend. ${error.message} Check that the backend is running and that the app is pointing to the correct local port.',
            isUser: false,
            isError: true,
            label: 'Connection issue',
            footer: 'Expected local backend on port 52445',
          ),
        );
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _messages.add(
          const _Message(
            text:
                'Something unexpected happened while contacting the assistant. Restart the backend and try again.',
            isUser: false,
            isError: true,
            label: 'Unexpected error',
            footer: 'Court Coach could not complete this request',
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
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showIntro = !_shouldCollapseIntro;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Court Coach'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: showIntro
                ? Column(
                    key: const ValueKey('chat-intro'),
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
                                  label: _isSending
                                      ? 'Thinking...'
                                      : 'Live replies',
                                ),
                                _InfoChip(
                                  icon: Icons.link_rounded,
                                  label: _sessionId == null
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
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: theme.cardColor.withOpacity(0.82),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Try one of these prepared questions',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (final quickReply in _quickReplies) ...[
                                    _QuickReplyButton(
                                      label: quickReply,
                                      enabled: !_isSending,
                                      onTap: () => _sendMessage(quickReply),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  if (_isSending)
                    const _TypingIndicatorBubble(),
                ],
              ),
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
                      focusNode: _inputFocusNode,
                      enabled: !_isSending,
                      textInputAction: TextInputAction.send,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: _isSending
                            ? 'Court Coach is replying...'
                            : 'Ask Court Coach...',
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
    );
  }
}

class _Message {
  const _Message({
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
