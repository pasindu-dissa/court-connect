import 'package:flutter/foundation.dart';

class AppConfig {
  static const int backendPort = 52445;

  static String get backendBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:$backendPort';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:$backendPort';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:$backendPort';
      default:
        return 'http://127.0.0.1:$backendPort';
    }
  }
}
