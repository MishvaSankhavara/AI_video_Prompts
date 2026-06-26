import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../utils/common_utils.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  factory NotificationService() {
    return instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    CommonUtils.printLog('>>> NOTIFICATION INIT: STARTING');

    // Initialize Timezone
    try {
      tz.initializeTimeZones();
      CommonUtils.printLog('>>> NOTIFICATION INIT: TIMEZONE DB LOADED');
      final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
      CommonUtils.printLog('>>> NOTIFICATION INIT: LOCAL TIMEZONE FETCHED -> ${timeZoneInfo.identifier}');
      tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));
      CommonUtils.printLog('>>> NOTIFICATION INIT: LOCATION SET');
    } catch (e, stacktrace) {
      CommonUtils.printLog('>>> NOTIFICATION INIT: TIMEZONE ERROR: $e\n$stacktrace');
    }

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('logo');

      final DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      CommonUtils.printLog('>>> NOTIFICATION INIT: CALLING PLUGIN INIT');
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          CommonUtils.printLog('Notification clicked: ${response.payload}');
        },
      );
      CommonUtils.printLog('>>> NOTIFICATION INIT: PLUGIN INIT SUCCESS');
    } catch (e, stacktrace) {
      CommonUtils.printLog('>>> NOTIFICATION INIT: PLUGIN INIT FAILED! ERROR: $e\n$stacktrace');
      rethrow;
    }

    _isInitialized = true;
    CommonUtils.printLog('>>> NOTIFICATION INIT: FULLY COMPLETE');
  }

  /// Fetches notifications from Firebase and schedules the next 7 days of alerts.
  Future<void> scheduleDailyNotifications() async {
    CommonUtils.printLog('>>> NOTIFICATION SCHEDULING: STARTING');
    try {
      // 1. Fetch data from Firebase Realtime Database
      CommonUtils.printLog('>>> NOTIFICATION SCHEDULING: FETCHING FIREBASE');
      final DataSnapshot snapshot = await FirebaseDatabase.instance.ref('notifications').get();
      if (!snapshot.exists || snapshot.value == null) {
        CommonUtils.printLog('>>> NOTIFICATION SCHEDULING: NO DATA IN FIREBASE!');
      } else {
        CommonUtils.printLog('>>> NOTIFICATION SCHEDULING: FIREBASE DATA FETCHED SUCCESSFULLY');
      }

      // Convert Firebase list to a List of Maps
      final List<Map<String, String>> fetchedNotifications = [];
      if (snapshot.value is List) {
        final List<dynamic> list = snapshot.value as List<dynamic>;
        for (var item in list) {
          if (item != null && item is Map) {
            fetchedNotifications.add({
              'title': item['title']?.toString() ?? '',
              'message': item['message']?.toString() ?? '',
            });
          }
        }
      } else if (snapshot.value is Map) {
        final Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
        map.forEach((key, value) {
          if (value is Map) {
            fetchedNotifications.add({
              'title': value['title']?.toString() ?? '',
              'message': value['message']?.toString() ?? '',
            });
          }
        });
      }

      if (fetchedNotifications.isEmpty) {
        CommonUtils.printLog('>>> NOTIFICATION SCHEDULING: FIREBASE WAS EMPTY. USING FALLBACK.');
        fetchedNotifications.add({
          'title': 'AI Video Prompts! 🚀',
          'message': 'Create amazing AI magic in just few seconds!'
        });
      }

      // 2. Clear existing scheduled notifications to prevent duplicates
      CommonUtils.printLog('>>> NOTIFICATION SCHEDULING: CANCELLING OLD ALARMS');
      await flutterLocalNotificationsPlugin.cancelAll();

      // 3. Schedule for the next 7 days (14 total notifications)
      final now = tz.TZDateTime.now(tz.local);
      final random = Random();

      // // --- TEMPORARY TEST NOTIFICATION ---
      // // This will fire 10 seconds after the app starts so you can test the new Logo!
      // if (fetchedNotifications.isNotEmpty) {
      //   CommonUtils.printLog('>>> NOTIFICATION SCHEDULING: SCHEDULING 10-SECOND TEST NOTIFICATION...');
      //   final testItem = fetchedNotifications[random.nextInt(fetchedNotifications.length)];
      //   await _scheduleNotification(
      //     id: 999,
      //     title: 'TEST: ${testItem['title']}',
      //     body: testItem['message']!,
      //     scheduledDate: now.add(const Duration(seconds: 10)),
      //   );
      //   CommonUtils.printLog('>>> NOTIFICATION SCHEDULING: TEST NOTIFICATION SCHEDULED SUCCESSFULLY!');
      // }

      for (int i = 0; i < 7; i++) {
        // --- MORNING NOTIFICATION (9:00 AM) ---
        var morningTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9, 0);
        morningTime = morningTime.add(Duration(days: i));
        // If the morning time has already passed today, skip to avoid immediate firing
        if (i == 0 && morningTime.isBefore(now)) {
          // Do not schedule for today's past morning
        } else {
          final morningItem = fetchedNotifications[random.nextInt(fetchedNotifications.length)];
          await _scheduleNotification(
            id: (i * 2), // Unique ID
            title: morningItem['title']!,
            body: morningItem['message']!,
            scheduledDate: morningTime,
          );
        }

        // --- EVENING NOTIFICATION (6:00 PM / 18:00) ---
        var eveningTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 18, 0);
        eveningTime = eveningTime.add(Duration(days: i));
        // If the evening time has already passed today, skip
        if (i == 0 && eveningTime.isBefore(now)) {
          // Do not schedule for today's past evening
        } else {
          final eveningItem = fetchedNotifications[random.nextInt(fetchedNotifications.length)];
          await _scheduleNotification(
            id: (i * 2) + 1, // Unique ID
            title: eveningItem['title']!,
            body: eveningItem['message']!,
            scheduledDate: eveningTime,
          );
        }
      }

      CommonUtils.printLog('>>> NOTIFICATION SCHEDULING: FULLY COMPLETED WITHOUT ERRORS!');
    } catch (e, stacktrace) {
      CommonUtils.printLog('>>> NOTIFICATION SCHEDULING FAILED: ERROR = $e\n$stacktrace');
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'daily_notifications_v2',
      'Daily Notifications',
      channelDescription: 'Daily reminders for new content',
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

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Request permissions on Android 13+ and iOS.
  Future<void> requestPermissions() async {
    CommonUtils.printLog('>>> NOTIFICATION PERMS: STARTING REQUEST');
    try {
      if (Platform.isIOS) {
        CommonUtils.printLog('>>> NOTIFICATION PERMS: REQUESTING IOS');
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        CommonUtils.printLog('>>> NOTIFICATION PERMS: IOS DONE');
      } else if (Platform.isAndroid) {
        CommonUtils.printLog('>>> NOTIFICATION PERMS: REQUESTING ANDROID');
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation == null) {
          CommonUtils.printLog('>>> NOTIFICATION PERMS: ERROR - androidImplementation is null!');
        } else {
          final bool? granted = await androidImplementation.requestNotificationsPermission();
          CommonUtils.printLog('>>> NOTIFICATION PERMS: ANDROID GRANTED? $granted');
        }
      }
    } catch (e, stacktrace) {
      CommonUtils.printLog('>>> NOTIFICATION PERMS: ERROR: $e\n$stacktrace');
      rethrow;
    }
    CommonUtils.printLog('>>> NOTIFICATION PERMS: COMPLETED');
  }
}
