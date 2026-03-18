// lib/features/health/data/health_notifier.dart

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import '../../../../core/services/health_service.dart';

class HealthNotifier extends ChangeNotifier {
  final HealthService _service = HealthService();

  int steps = 0;
  double calories = 0.0;
  List<HealthDataPoint> heartRateData = [];

  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';

  bool get isAuthorized => _service.isAuthorized;

  /// Load all health data at once
  Future<void> loadAll() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      // Request auth if not yet granted
      if (!_service.isAuthorized) {
        final granted = await _service.requestAuthorization();
        if (!granted) {
          hasError = true;
          errorMessage = 'Health permissions denied.';
          isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Fetch in parallel
      final results = await Future.wait([
        _service.fetchSteps(),
        _service.fetchCalories(),
        _service.fetchHeartRate(),
      ]);

      steps = results[0] as int;
      calories = results[1] as double;
      heartRateData = results[2] as List<HealthDataPoint>;
    } catch (e) {
      hasError = true;
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  void clearError() {
    hasError = false;
    errorMessage = '';
    notifyListeners();
  }
}