import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:local_notifier/local_notifier.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'dart:io';
import 'dart:developer' as dev;
import 'dart:async';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Map<int, Timer> _activeTimers = {};

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    try {
      final String currentTimeZone = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      // Fallback to Ashgabat if detection fails
      tz.setLocalLocation(tz.getLocation('Asia/Ashgabat'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    if (Platform.isWindows) {
      await localNotifier.setup(
        appName: 'Sanly Timer',
        shortcutPolicy: ShortcutPolicy.requireCreate,
      );
    }

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
    );

    if (Platform.isAndroid) {
      await requestPermissions();
    }
  }

  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    final bool? granted = await androidImplementation
        ?.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<bool> checkExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    return await androidImplementation?.canScheduleExactNotifications() ??
        false;
  }

  Future<void> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return;

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestExactAlarmsPermission();
  }

  Future<void> scheduleReminder({
    required int sessionId,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final now = DateTime.now();

    if (scheduledTime.isBefore(now)) return;

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    final bool? canScheduleExact = await androidImplementation
        ?.canScheduleExactNotifications();

    if (canScheduleExact == false) {
      await androidImplementation?.requestExactAlarmsPermission();
    }

    final scheduleMode = (canScheduleExact ?? false)
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'billiard-timer-reminders-v2-1',
          'Sessiýa Ýatlatmalary',
          channelDescription: 'Wagty dolan sessiýalar üçin duýduruşlar',
          importance: Importance.max,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound('s1'),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          // fullScreenIntent aýryldy (stabil däl bolup bilýändigi üçin)
          category: AndroidNotificationCategory.alarm,
        );

    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      sound: '1.mp3',
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    try {
      if (Platform.isWindows) {
        final notificationId = sessionId % 2147483647;
        
        // Öňki timer bar bolsa öçürýäris
        _activeTimers[notificationId]?.cancel();

        final notification = LocalNotification(title: title, body: body);
        final delay = scheduledTime.difference(DateTime.now());

        if (delay.isNegative) {
          notification.show();
        } else {
          _activeTimers[notificationId] = Timer(delay, () {
            notification.show();
            _activeTimers.remove(notificationId);
          });
        }
        return;
      }

      final int notificationId = sessionId % 2147483647;

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local),
        details,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      dev.log("Notification schedule error: $e");
    }
  }

  Future<void> showTestNotification() async {
    if (Platform.isWindows) {
      final notification = LocalNotification(
        title: 'Sesi barlanýar',
        body: 'Duýduruş sesini eşidýän bolsaňyz, hemme zat dogry işleýär.',
      );
      notification.show();
      return;
    }

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'billiard-timer-test-channel',
          'Synag duýduruşy',
          channelDescription: 'Sesi barlamak üçin synag bildirişi',
          importance: Importance.max,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound('s1'),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      999999,
      'Sesi barlanýar',
      'Duýduruş sesini eşidýän bolsaňyz, hemme zat dogry işleýär.',
      details,
    );
  }

  Future<void> cancelReminder(int sessionId) async {
    final int notificationId = sessionId % 2147483647;
    
    if (Platform.isWindows) {
      _activeTimers[notificationId]?.cancel();
      _activeTimers.remove(notificationId);
    }
    
    await _notificationsPlugin.cancel(notificationId);
  }
}
