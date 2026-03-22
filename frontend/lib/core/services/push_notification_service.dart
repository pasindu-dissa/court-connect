import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/api_constants.dart';                              

// --- Background Message Handler (MUST be a top-level function) ---
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  dev.log("Handling a background message: ${message.messageId}");
}

class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Request permissions (crucial for iOS and Android 13+)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      dev.log('User granted notification permissions');
    }

    // 2. Set up Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Set up Foreground Notifications (Local Notifications)
    const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    
    await _localNotificationsPlugin.initialize(initSettings);

    // Create an Android Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', 
      'High Importance Notifications', 
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Listen to Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  // 5. Get Device Token to send to your Node.js Backend
  static Future<String?> getDeviceToken() async {
    try {
      String? token = await _fcm.getToken();
      dev.log("FCM Device Token: $token");
      return token;
    } catch (e) {
      dev.log("Failed to get FCM token: $e");
      return null;
    }
  }

  // NEW: Send token to your Node.js backend
  static Future<void> updateTokenOnBackend() async {
    try {
      // 1. Get the FCM Device Token
      String? fcmToken = await getDeviceToken();
      if (fcmToken == null) return;

      // 2. Get the current user's Firebase Auth Token (for your backend's 'protect' middleware)
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;
      
      String? authToken = await currentUser.getIdToken();

      // 3. Send the HTTP PUT request
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/update-fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken', // Authenticate the request
        },
        body: jsonEncode({
          'fcmToken': fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        dev.log("✅ Successfully saved FCM token to MongoDB!");
      } else {
        dev.log("❌ Failed to save FCM token: ${response.body}");
      }
    } catch (e) {
      dev.log("❌ Error sending FCM token to backend: $e");
    }
  }
}
