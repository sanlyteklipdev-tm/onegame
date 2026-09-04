import 'dart:developer' as dev;
import 'dart:io';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'booking_watch_task.dart';

/// Işgäriň bronlaryna serediji fon hyzmatyny dolandyrýar.
///
/// Diňe Android-de işleýär. Kompýuterde programma hemişe açyk durýar,
/// şonuň üçin oňa beýle hyzmat gerek däl.
class BookingWatchService {
  BookingWatchService._();

  static const int _serviceId = 512;

  /// Baza her 15 sekuntda soralýar. Ekrandaky sanaw 2 sekuntda
  /// täzelenýär, ýöne fonda beýle ýygylyk batareýany biderek iýerdi —
  /// bron duýduryşy üçin 15 sekunt ýeterlik.
  static const int _intervalMs = 15000;

  static bool get _supported => Platform.isAndroid;

  /// Programma açylanda bir gezek çagyrylýar
  static void init() {
    if (!_supported) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'sanly_booking_watch',
        channelName: 'Bronlara gözegçilik',
        channelDescription:
            'Programma ýapyk wagty hem bron habarlaryny almak üçin',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(_intervalMs),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  /// Gerek rugsatlary soraýar. Ulanyjy ret etse hyzmat işlemez,
  /// ýöne programma işlemegini dowam edýär.
  static Future<void> requestPermissions() async {
    if (!_supported) return;

    final permission = await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    // Batareýa optimizasiýasy hyzmaty öldürýär — muny soramaly
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }
  }

  /// Işgär girende başlanýar
  static Future<void> start({required String employeeName}) async {
    if (!_supported) return;

    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.restartService();
        return;
      }

      await FlutterForegroundTask.startService(
        serviceId: _serviceId,
        serviceTypes: [ForegroundServiceTypes.dataSync],
        notificationTitle: 'Sanly Timer işleýär',
        notificationText: '$employeeName — bronlara garaşylýar',
        callback: startBookingWatchCallback,
      );
    } catch (e) {
      dev.log('BookingWatch start failed: $e');
    }
  }

  static Future<void> stop() async {
    if (!_supported) return;
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
      }
    } catch (e) {
      dev.log('BookingWatch stop failed: $e');
    }
  }
}
