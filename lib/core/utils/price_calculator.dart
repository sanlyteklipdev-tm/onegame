/// Calculates costs for billiard sessions based on time segments.
class PriceCalculator {
  PriceCalculator._();

  static const double _secondsPerHour = 3600.0;

  /// Bir segment üçin oýunça düşýän hasap
  ///
  /// [pricePerHour] Stolun sagatlyk bahasy (TMT)
  /// [durationSeconds] Segment dowamlylygy (sekunt)
  /// [playerCount] Şol segmentde aktiw oýunçy sany
  static double segmentCostPerPlayer({
    required double pricePerHour,
    required double durationSeconds,
    required int playerCount,
  }) {
    if (playerCount <= 0 || durationSeconds <= 0) return 0.0;
    final totalSegmentCost = (durationSeconds / _secondsPerHour) * pricePerHour;
    return totalSegmentCost / playerCount;
  }

  /// Sessiýanyň häzirki real-time bahasy (aktiw sessiýa üçin)
  ///
  /// [accumulatedCost] Soňky checkpointiň öňünden ýygnan bahasy
  /// [lastCheckpointTime] Soňky checkpoint wagty
  /// [pricePerHour] Stolun sagatlyk bahasy
  /// [currentActiveCount] Häzirki aktiw oýunçy sany
  static double currentSessionCost({
    required double accumulatedCost,
    required DateTime lastCheckpointTime,
    required double pricePerHour,
    required int currentActiveCount,
  }) {
    final elapsed = DateTime.now().difference(lastCheckpointTime);
    final currentSegment = segmentCostPerPlayer(
      pricePerHour: pricePerHour,
      durationSeconds: elapsed.inMilliseconds / 1000.0,
      playerCount: currentActiveCount,
    );
    return accumulatedCost + currentSegment;
  }

  /// Calculates costs for billiard sessions based on time segments.
  static double tableTotalCurrentCost({
    required List<double> sessionAccumulatedCosts,
    required DateTime lastCheckpointTime,
    required double pricePerHour,
    required int currentActiveCount,
  }) {
    if (sessionAccumulatedCosts.isEmpty) return 0.0;

    final elapsed = DateTime.now().difference(lastCheckpointTime);
    final segmentSeconds = elapsed.inMilliseconds / 1000.0;
    final segmentTotal = currentActiveCount > 0
        ? (segmentSeconds / _secondsPerHour) * pricePerHour
        : 0.0;

    final accumulated = sessionAccumulatedCosts.fold(0.0, (a, b) => a + b);
    return accumulated + segmentTotal;
  }

  /// Checkpoint wagty: oýunçy sany üýtgäende ähli aktiw sessiýalary "hesap et"
  /// Qaýtarýar: her sessiýa üçin goşulmaly summa map-y {sessionId: addedCost}
  static Map<int, double> calculateCheckpointDeltas({
    required List<({int id, double accumulatedCost, DateTime lastCheckpoint})>
    activeSessions,
    required double pricePerHour,
    required DateTime now,
  }) {
    final count = activeSessions.length;
    final result = <int, double>{};

    for (final session in activeSessions) {
      final elapsed = now.difference(session.lastCheckpoint);
      final delta = segmentCostPerPlayer(
        pricePerHour: pricePerHour,
        durationSeconds: elapsed.inMilliseconds / 1000.0,
        playerCount: count,
      );
      result[session.id] = delta;
    }

    return result;
  }

  /// Wagt formatlaşdyrma: HH:MM:SS
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Bahany TMT formatda görkez
  static String formatPrice(double price) {
    if (price < 10) return price.toStringAsFixed(2);
    return price.toStringAsFixed(1);
  }
}
