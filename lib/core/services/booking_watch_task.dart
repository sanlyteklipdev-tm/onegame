import 'dart:developer' as dev;
import 'dart:ui';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../../data/models/reservation_model.dart';
import '../../data/repositories/pg/pg_reservation_repository.dart';
import '../../data/remote/postgres_service.dart';
import '../utils/formatters.dart';
import 'credential_store.dart';
import 'notification_service.dart';
import 'reservation_notifications.dart';

/// Fon hyzmatynyň giriş nokady. Aýry izolýatda işleýär, şonuň üçin
/// bu funksiýa hökman ýokary derejede bolmaly we `vm:entry-point`
/// bellik almaly — ýogsam release ýygnamada aýrylýar.
@pragma('vm:entry-point')
void startBookingWatchCallback() {
  FlutterForegroundTask.setTaskHandler(BookingWatchTask());
}

/// Işgäriň bronlaryna serediji fon hyzmaty.
///
/// Programma ýapyk bolsa-da işleýär: bazany yzygiderli soraýar we
/// täze bron bellenende habar berýär. 30 minut öň we başlaýan
/// pursadyndaky duýduryşlary hem şu ýerden belleýär.
class BookingWatchTask extends TaskHandler {
  /// Habar berlen bronlar — gaýtalanmaz ýaly
  final Set<int> _seen = {};

  /// Duýduryş bellenen wagtlar
  final Map<int, DateTime> _scheduled = {};

  int? _employeeId;

  /// Baza birikme taýýarmy
  bool _ready = false;

  /// Duýduryş plugini taýýarmy. Bazadan aýry saklanýar: duýduryş
  /// bellenmese-de baza soragy dowam etmeli, we tersine.
  bool _notificationsReady = false;

  /// Ilkinji aýlawda bar bolan bronlar barada habar berilmeýär
  bool _firstPass = true;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Fon hyzmaty aýry izolýatda işleýär. Pluginler ol ýerde özleri
    // hasaba durmaýar — şuny çagyrmasaň, duýduryş plugini "beýle
    // metod ýok" diýip ýalňyşlyk atýar.
    DartPluginRegistrant.ensureInitialized();

    final creds = await CredentialStore.read();
    if (creds == null || creds.employeeId == null) {
      dev.log('BookingWatch: no stored credentials, stopping');
      await FlutterForegroundTask.stopService();
      return;
    }

    _employeeId = creds.employeeId;

    await _ensureNotifications();
    await _ensureConnection();
  }

  /// Duýduryş plugini bir gezek taýýarlanýar. Şowsuz bolsa baza
  /// işine päsgel bermeýär — indiki aýlawda ýene synanyşylýar.
  Future<void> _ensureNotifications() async {
    if (_notificationsReady) return;
    try {
      await NotificationService().initialize();
      _notificationsReady = true;
    } catch (e) {
      dev.log('BookingWatch: notification init failed: $e');
    }
  }

  Future<void> _ensureConnection() async {
    if (_ready) return;
    final creds = await CredentialStore.read();
    if (creds == null) return;
    try {
      await PostgresService.signIn(
        username: creds.username,
        password: creds.password,
      );
      _ready = true;
    } catch (e) {
      // Wifi ýok bolsa indiki aýlawda ýene synanyşylýar
      dev.log('BookingWatch: connect failed: $e');
    }
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    _tick();
  }

  Future<void> _tick() async {
    final employeeId = _employeeId;
    if (employeeId == null) return;

    await _ensureNotifications();

    // Baglanyşyk ýitse (wifi kesildi) täzeden dikeldilýär
    await _ensureConnection();
    if (!_ready) return;

    List<ReservationModel> bookings;
    try {
      final repo = PgReservationRepository();
      bookings = await repo
          .watchForEmployee(
            employeeId,
            from: AppFormatters.startOfDay(DateTime.now()),
          )
          .first;
    } catch (e) {
      dev.log('BookingWatch: poll failed: $e');
      // Diňe baza ýalňyşlygynda birikme täzeden açylýar
      _ready = false;
      return;
    }

    // Duýduryş ýalňyşlygy birikmä degişli däl — aýry tutulýar,
    // ýogsam her aýlawda baza biderek täzeden birigerdi
    try {
      await _handle(bookings);
    } catch (e) {
      dev.log('BookingWatch: notify failed: $e');
    }
  }

  Future<void> _handle(List<ReservationModel> bookings) async {
    final notifier = NotificationService();
    final currentIds = <int>{};

    for (final r in bookings) {
      currentIds.add(r.id);

      if (r.isDone) {
        if (_scheduled.remove(r.id) != null) {
          await ReservationNotifications.cancel(r.id);
        }
        continue;
      }

      final line =
          '${r.title} · ${AppFormatters.formatTime(r.startTime)}';

      if (!_seen.contains(r.id)) {
        _seen.add(r.id);
        if (!_firstPass) {
          await notifier.showNow(
            id: r.id,
            title: 'Täze bron',
            body: line,
          );
        }
      }

      if (_scheduled[r.id] != r.startTime) {
        _scheduled[r.id] = r.startTime;
        try {
          await ReservationNotifications.schedule(
            reservationId: r.id,
            startTime: r.startTime,
            soonTitle: '30 minutdan bron',
            soonBody: line,
            startTitle: 'Bronuň wagty geldi',
            startBody: line,
          );
        } catch (e) {
          dev.log('BookingWatch: schedule failed: $e');
        }
      }
    }

    for (final id in _scheduled.keys.toList()) {
      if (!currentIds.contains(id)) {
        _scheduled.remove(id);
        await ReservationNotifications.cancel(id);
      }
    }

    _seen.retainWhere(currentIds.contains);
    _firstPass = false;
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await PostgresService.close();
  }
}
