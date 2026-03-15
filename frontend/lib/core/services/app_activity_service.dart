class AppActivityService {
  AppActivityService._();

  static final AppActivityService instance = AppActivityService._();

  final List<Map<String, Object?>> _events = [];
  String _currentScreen = 'home';
  String? _selectedSport;
  String? _searchQuery;
  String? _selectedCourt;
  String _bookingView = 'map';
  int _selectedFilterCount = 0;

  void recordScreenView(String screen) {
    _currentScreen = screen;
    _pushEvent(
      type: 'screen_view',
      label: screen,
    );
  }

  void recordBookingState({
    String? selectedSport,
    String? searchQuery,
    String? selectedCourt,
    String? bookingView,
    int? selectedFilterCount,
  }) {
    if (selectedSport != null) {
      _selectedSport = selectedSport;
    }
    if (searchQuery != null) {
      _searchQuery = searchQuery;
    }
    if (selectedCourt != null) {
      _selectedCourt = selectedCourt;
    }
    if (bookingView != null) {
      _bookingView = bookingView;
    }
    if (selectedFilterCount != null) {
      _selectedFilterCount = selectedFilterCount;
    }

    _pushEvent(
      type: 'booking_state',
      label: _selectedCourt ?? _searchQuery ?? _selectedSport ?? _bookingView,
      details: {
        'selectedSport': _selectedSport,
        'searchQuery': _searchQuery,
        'selectedCourt': _selectedCourt,
        'bookingView': _bookingView,
        'selectedFilterCount': _selectedFilterCount,
      },
    );
  }

  Map<String, dynamic> buildContextPayload() {
    return {
      'currentScreen': _currentScreen,
      'bookingView': _bookingView,
      'selectedSport': _selectedSport,
      'searchQuery': _searchQuery,
      'selectedCourt': _selectedCourt,
      'selectedFilterCount': _selectedFilterCount,
      'recentEvents': _events.reversed.take(8).toList(),
    };
  }

  void _pushEvent({
    required String type,
    String? label,
    Map<String, Object?>? details,
  }) {
    _events.add({
      'type': type,
      'label': label,
      'details': details,
      'timestamp': DateTime.now().toIso8601String(),
    });

    if (_events.length > 24) {
      _events.removeAt(0);
    }
  }
}
