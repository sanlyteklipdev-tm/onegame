import 'notification_service.dart';

/// Bron duýduryşlary: her bron üçin iki sany —
/// 30 minut öňünden we bron başlaýan pursadynda.
///
/// Duýduryş ID-leri sessiýalaryňkydan aýry aralykda saklanýar
/// (sessiýalar öz kiçi id-lerini ulanýar), şeýlelikde çaknyşyk bolmaýar.
class ReservationNotifications {
  ReservationNotifications._();

  static const int _idBase = 1000000;
  static const Duration leadTime = Duration(minutes: 30);

  static int _soonId(int reservationId) => _idBase + reservationId * 2;
  static int _startId(int reservationId) => _idBase + reservationId * 2 + 1;

  /// Öňki duýduryşlary çalşyp, brona täzeden duýduryş belleýär.
  static Future<void> schedule({
    required int reservationId,
    required DateTime startTime,
    required String soonTitle,
    required String soonBody,
    required String startTitle,
    required String startBody,
  }) async {
    await cancel(reservationId);

    final notifier = NotificationService();

    await notifier.scheduleReminder(
      sessionId: _soonId(reservationId),
      title: soonTitle,
      body: soonBody,
      scheduledTime: startTime.subtract(leadTime),
    );

    await notifier.scheduleReminder(
      sessionId: _startId(reservationId),
      title: startTitle,
      body: startBody,
      scheduledTime: startTime,
    );
  }

  static Future<void> cancel(int reservationId) async {
    final notifier = NotificationService();
    await notifier.cancelReminder(_soonId(reservationId));
    await notifier.cancelReminder(_startId(reservationId));
  }
}
