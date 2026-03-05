import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  HealthService._internal();

  final Health _health = Health();

  // Data types we want to read from Google Fit / Health Connect
  static const List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  bool _isAuthorized = false;
  bool get isAuthorized => _isAuthorized;

  /// Check if health permissions are already granted
  Future<bool> hasPermissions() async {
    return await _health.hasPermissions(_dataTypes) ?? false;
  }
}