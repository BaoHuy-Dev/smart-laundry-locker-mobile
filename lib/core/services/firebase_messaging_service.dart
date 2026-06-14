import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:smart_laundry_locker/features/courier_dispatch/presentation/widgets/incoming_order_sheet.dart';
import 'package:smart_laundry_locker/core/services/app_messenger_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';

/// Top-level background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  debugPrint("Handling a background message: ${message.messageId}");
}

class FirebaseMessagingService {
  FirebaseMessagingService._();
  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<RemoteMessage> _messageStreamController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onMessageReceived =>
      _messageStreamController.stream;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // 1. Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false, // handled below via requestPermission
          requestBadgePermission: false,
          requestSoundPermission: false,
        );
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    // Create Android Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'aisl_high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // Request Android 13+ notification permission explicitly
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // 2. Request permissions (FCM)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // iOS: Allow FCM to show banners while app is in foreground
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // 3. Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Setup foreground messaging listeners
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Handle any interaction when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // 6. Check if app was opened via a notification when terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    _initialized = true;
  }

  /// Get the device FCM token (useful for sending to your backend to register this device)
  Future<String?> getToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      debugPrint("FCM Token: $token");
      return token;
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
      return null;
    }
  }

  /// Sync device token to backend using general API client
  Future<void> updateBackendDeviceToken(ApiClient apiClient) async {
    try {
      final token = await getToken();
      if (token == null) return;

      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString('aisl_app_device_id');
      if (deviceId == null) {
        deviceId =
            'DEV-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(99999)}';
        await prefs.setString('aisl_app_device_id', deviceId);
      }

      final String platform = defaultTargetPlatform == TargetPlatform.iOS
          ? 'IOS'
          : 'ANDROID';

      final response = await apiClient.post(
        '/api/notifications/fcm-tokens',
        data: {'token': token, 'deviceType': platform, 'deviceId': deviceId},
      );
      debugPrint(
        "FCM Token successfully registered with backend: ${response.statusCode}",
      );
    } catch (e) {
      debugPrint("Failed to update device token on backend: $e");
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    debugPrint('Message data: ${message.data}');

    if (message.notification != null) {
      debugPrint(
        'Message also contained a notification: ${message.notification}',
      );
    }

    final type = message.data['type'];

    // Push to stream so listeners (like NotificationProvider) can refresh
    _messageStreamController.add(message);

    // Always show a local notification banner (handles both notification+data
    // messages and pure data-only messages from the backend)
    _showLocalNotification(message);

    if (type == 'dispatch_order') {
      _showIncomingOrderDialog(message.data);
    } else {
      // General notification fallback -> Snack bar
      final title =
          message.notification?.title ??
          message.data['title'] as String? ??
          'Thông báo mới';
      SmartDialog.showToast(title);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    // Prefer the FCM notification object; fall back to data fields
    // (data-only messages from the backend will not have a notification object)
    final title =
        message.notification?.title ??
        message.data['title'] as String? ??
        'Thông báo';
    final body =
        message.notification?.body ??
        message.data['content'] as String? ??
        message.data['body'] as String? ??
        '';

    if (title.isEmpty && body.isEmpty) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'aisl_high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: platformDetails,
      payload: message.data.toString(),
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint("Message opened app: ${message.data}");
    // Handle Navigation based on data payload
    // e.g if type == 'dispatch_order', navigate to Dispatch Map or show Dialog
  }

  void _showIncomingOrderDialog(Map<String, dynamic> data) {
    final context = AppMessengerService.scaffoldMessengerKey.currentContext;
    if (context == null) return;

    showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return IncomingOrderSheet(
          dispatchData: data,
          onAccept: () {
            // Trigger CourierDeliveryProvider -> acceptOrder(dispatchId)
            // Note: Navigation/Logic will be handled by the provider state change
            SmartDialog.showToast('Đã nhận đơn hàng!');
            // TODO: Route to Active Delivery Screen
          },
          onDecline: () {
            SmartDialog.showToast('Đã từ chối đơn hàng');
          },
        );
      },
    );
  }
}
