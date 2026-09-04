import 'dart:developer' as dev;
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/reservation_model.dart';
import 'notification_service.dart';
import 'reservation_notifications.dart';

/// Işgäriň bronlary üýtgände duýduryşlary sazlaýar.
///
/// Üç ýagdaýda habar berilýär:
///   1. täze bron bellenende — şol pursat,
///   2. başlamazyndan 30 minut öň,
///   3. başlaýan pursadynda.
///
/// 2 we 3 ulgamyň buduryjysy arkaly bellenýär — programma ýapyk
/// bolsa-da gelýär. 1 welin programma işläp durka görünýär, sebäbi
/// täze brony görmek üçin baza soralmaly.
class WorkerNotificationSync {
  WorkerNotificationSync._();

  static const _seenKey = 'worker_seen_reservation_ids';

  /// Eýýäm habar berlen bronlar
  static final Set<int> _seen = {};

  /// Duýduryş bellenen wagtlar: {reservationId: startTime}.
  /// Wagt üýtgemedik bolsa gaýtadan bellenmeýär — sanaw her
  /// 2 sekuntda täzelenýär, her gezek täzeden bellemek artykmaç.
  static final Map<int, DateTime> _scheduled = {};

  static bool _loaded = false;

  /// Sanawyň soňky görnüşi. Bron sanawy her 2 sekuntda gaýtadan
  /// okalýar, ýöne köplenç üýtgemeýär — üýtgemedik bolsa hiç zat
  /// edilmeýär, ýogsam disk her 2 sekuntda ýazylardy.
  static String _lastSignature = '';

  /// Bir wagtda iki gezek işlemez ýaly
  static bool _running = false;

  static String _signatureOf(List<ReservationModel> bookings) => bookings
      .map(
        (r) => '${r.id}:${r.startTime.millisecondsSinceEpoch}:${r.status.name}',
      )
      .join(',');

  /// Ilkinji açylyşda bar bolan bronlar barada habar berilmeýär —
  /// ýogsam programma her gurnalanda birbada ähli bronlar çykardy.
  static bool _firstRun = false;

  static Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();

    _firstRun = !prefs.containsKey(_seenKey);
    _seen
      ..clear()
      ..addAll(
        (prefs.getStringList(_seenKey) ?? [])
            .map(int.tryParse)
            .whereType<int>(),
      );
    _loaded = true;
  }

  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _seenKey,
      _seen.map((e) => e.toString()).toList(),
    );
  }

  /// Ähli ýazgylary poz — ulgamdan çykylanda çagyrylýar,
  /// başga adam giren enjamda öňki adamyň duýduryşlary galmaz ýaly.
  static Future<void> clear() async {
    for (final id in _scheduled.keys.toList()) {
      await ReservationNotifications.cancel(id);
    }
    _scheduled.clear();
    _seen.clear();
    _loaded = false;
    _lastSignature = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_seenKey);
  }

  /// Bronlaryň häzirki sanawyna görä duýduryşlary sazlaýar.
  ///
  /// Ýazgylaryň teksti daşyndan berilýär — dil çalşyp bilýär.
  static Future<void> sync({
    required List<ReservationModel> bookings,
    required String Function(ReservationModel) newTitle,
    required String Function(ReservationModel) newBody,
    required String Function(ReservationModel) soonTitle,
    required String Function(ReservationModel) soonBody,
    required String Function(ReservationModel) startTitle,
    required String Function(ReservationModel) startBody,
  }) async {
    // Android-de duýduryşlary fon hyzmaty belleýär — programma hem
    // bellese, her habar iki gezek gelerdi. Kompýuterde fon hyzmaty
    // ýok, şonuň üçin ol ýerde şu işleýär.
    if (Platform.isAndroid) return;

    if (_running) return;

    final signature = _signatureOf(bookings);
    if (signature == _lastSignature) return;

    _running = true;
    try {
      await _apply(
        bookings: bookings,
        newTitle: newTitle,
        newBody: newBody,
        soonTitle: soonTitle,
        soonBody: soonBody,
        startTitle: startTitle,
        startBody: startBody,
      );
      _lastSignature = signature;
    } finally {
      _running = false;
    }
  }

  static Future<void> _apply({
    required List<ReservationModel> bookings,
    required String Function(ReservationModel) newTitle,
    required String Function(ReservationModel) newBody,
    required String Function(ReservationModel) soonTitle,
    required String Function(ReservationModel) soonBody,
    required String Function(ReservationModel) startTitle,
    required String Function(ReservationModel) startBody,
  }) async {
    await load();

    final notifier = NotificationService();
    final currentIds = <int>{};

    for (final r in bookings) {
      currentIds.add(r.id);

      // Ýerine ýetirilen bron üçin duýduryş gerek däl
      if (r.isDone) {
        if (_scheduled.remove(r.id) != null) {
          await ReservationNotifications.cancel(r.id);
        }
        continue;
      }

      final isNew = !_seen.contains(r.id);
      if (isNew) {
        _seen.add(r.id);
        if (!_firstRun) {
          await notifier.showNow(
            id: r.id,
            title: newTitle(r),
            body: newBody(r),
          );
        }
      }

      // Wagt üýtgän ýa-da ilkinji gezek görlen bolsa täzeden belle
      if (_scheduled[r.id] != r.startTime) {
        _scheduled[r.id] = r.startTime;
        try {
          await ReservationNotifications.schedule(
            reservationId: r.id,
            startTime: r.startTime,
            soonTitle: soonTitle(r),
            soonBody: soonBody(r),
            startTitle: startTitle(r),
            startBody: startBody(r),
          );
        } catch (e) {
          // Duýduryş bellenmese-de sanaw işlemegini dowam etsin
          dev.log('Worker reminder schedule failed: $e');
        }
      }
    }

    // Sanawdan çykan bronlar (pozuldy ýa geçdi) — duýduryşy ýatyr
    for (final id in _scheduled.keys.toList()) {
      if (!currentIds.contains(id)) {
        _scheduled.remove(id);
        await ReservationNotifications.cancel(id);
      }
    }

    if (_firstRun) _firstRun = false;
    _seen.retainWhere(currentIds.contains);
    await _save();
  }
}
