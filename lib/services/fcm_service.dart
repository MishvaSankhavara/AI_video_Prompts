import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;
import 'package:provider/provider.dart';

import '../utils/common_utils.dart';
import '../widgets/dialog/notification_offer_dialog.dart';
import '../screens/category/category_details_screen.dart';
import '../services/navigation_service.dart';
import '../viewmodel/fetch_video_category.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // CommonUtils.printLog("Handling a background message: ${message.messageId}");
}

class FcmService {
  static final FcmService instance = FcmService._internal();

  factory FcmService() {
    return instance;
  }

  FcmService._internal();

  bool _isInitialized = false;
  final ValueNotifier<Map<String, dynamic>?> _pendingNotificationData =
      ValueNotifier(null);

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Set up Firebase Messaging
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get FCM token
    FirebaseMessaging.instance.getToken().then((token) {
      CommonUtils.printLog('>>> FCM Token: $token');
    });

    // Listen to token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      CommonUtils.printLog('>>> FCM Token Refreshed: $token');
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      CommonUtils.printLog('>>> Got a message whilst in the foreground!');
      CommonUtils.printLog('>>> Message data: ${message.data}');

      if (message.notification != null) {
        CommonUtils.printLog(
          '>>> Message also contained a notification: ${message.notification}',
        );
        // Show local notification using flutter_local_notifications from NotificationService
        _showForegroundNotification(message);
      }
    });

    // Handle when app is opened from a background state via a push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      CommonUtils.printLog(
        '>>> Message opened app from background: ${message.messageId}',
      );
      _pendingNotificationData.value = message.data;
    });

    // Handle when app is opened from a terminated state via a push notification
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        CommonUtils.printLog(
          '>>> Message opened app from terminated state: ${message.messageId}',
        );
        _pendingNotificationData.value = message.data;
      }
    });

    _isInitialized = true;
  }

  /// Request permissions for FCM on iOS and Android 13+
  Future<void> requestPermissions() async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } catch (e) {
      CommonUtils.printLog('>>> FCM PERMS ERROR: $e');
    }
  }

  /// Sets up a listener that watches for notification payload data
  /// and shows the offer dialog if applicable. Call this in the main shell (e.g. BottomNavBarScreen).
  void setupNotificationListener(BuildContext context) {
    void handleNotificationData() {
      if (!context.mounted) return;
      final data = _pendingNotificationData.value;
      if (data != null && data.isNotEmpty) {
        final String? categoryIdStr = data['category_id']?.toString();
        final String imageUrl = data['image_url']?.toString() ?? '';
        final String title = data['title']?.toString() ?? '';
        final String message = data['message']?.toString() ?? '';

        // Nullify the payload so we don't show the dialog again
        _pendingNotificationData.value = null;

        if (categoryIdStr != null) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => NotificationOfferDialog(
              title: title,
              message: message,
              imageUrl: imageUrl,
              onTryNow: () {
                Navigator.of(context).pop(); // Close dialog

                int categoryId = int.tryParse(categoryIdStr) ?? 0;

                String actualCategoryName = 'Featured Collection';
                final categoryVM = Provider.of<FetchVideoCategoryViewModel>(
                  context,
                  listen: false,
                );
                for (var cat in categoryVM.categories) {
                  if (cat.categoryId == categoryId) {
                    actualCategoryName = cat.categoryName;
                    break;
                  }
                }

                NavigationService.push(
                  context,
                  CategoryDetailsScreen(
                    categoryId: categoryId,
                    categoryName: actualCategoryName,
                  ),
                );
              },
            ),
          );
        }
      }
    }

    _pendingNotificationData.addListener(handleNotificationData);
    // Check immediately in case there's already pending data on load, but wait for the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleNotificationData();
    });
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'fcm_foreground_channel',
          'FCM Notifications',
          channelDescription: 'Foreground notifications from FCM',
          importance: Importance.max,
          priority: Priority.high,
          largeIcon: DrawableResourceAndroidBitmap('logo'),
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Trigger local notification via the NotificationService's plugin instance
    await NotificationService.instance.flutterLocalNotificationsPlugin.show(
      id: message.notification.hashCode,
      title: message.notification?.title ?? '',
      body: message.notification?.body ?? '',
      notificationDetails: platformChannelSpecifics,
    );
  }
}
