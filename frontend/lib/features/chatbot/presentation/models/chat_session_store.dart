class ChatSessionStore {
  ChatSessionStore._();

  static final ChatSessionStore instance = ChatSessionStore._();

  final List<Map<String, Object?>> _messages = [
    {
      'text':
          'Hi, I am Court Coach. I can help with bookings, player invites, venue questions, and match prep.',
      'isUser': false,
      'label': 'Court Coach',
      'footer': 'Ready to connect to live assistant',
      'isError': false,
    },
  ];

  List<String> _quickReplies = const [
    'Can you find an evening badminton court for me?',
    'Can you draft a player invite message?',
    'What should I pack for match day?',
    'Can you help me find doubles players?',
    'Which courts are best for beginners?',
    'How early should I arrive for my game?',
  ];

  String? _sessionId;
  bool _hasOpenedPreparedQuestions = false;

  List<Map<String, Object?>> get messages =>
      List<Map<String, Object?>>.from(_messages);

  List<String> get quickReplies => List<String>.from(_quickReplies);

  String? get sessionId => _sessionId;

  bool get hasOpenedPreparedQuestions => _hasOpenedPreparedQuestions;

  void setSessionId(String? value) {
    _sessionId = value;
  }

  void setQuickReplies(List<String> values) {
    _quickReplies = List<String>.from(values);
  }

  void setHasOpenedPreparedQuestions(bool value) {
    _hasOpenedPreparedQuestions = value;
  }

  void addMessage({
    required String text,
    required bool isUser,
    String? label,
    String? footer,
    bool isError = false,
  }) {
    _messages.add({
      'text': text,
      'isUser': isUser,
      'label': label,
      'footer': footer,
      'isError': isError,
    });
  }
}
