import 'dart:math';
import 'package:intl/intl.dart';

/// ─── Sessiýa kody generatory ───────────────────────────────
class CodeGenerator {
  CodeGenerator._();

  static const String _upperChars = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const String _lowerChars = 'abcdefghjkmnpqrstuvwxyz';
  static const String _digits = '23456789';

  static final Random _random = Random.secure();

  /// 7 simwolly unique kod: 'FeWdj32' görnüşinde
  static String generateSessionCode() {
    final chars = _upperChars + _lowerChars + _digits;
    final firstChar = _upperChars[_random.nextInt(_upperChars.length)];
    final rest = List.generate(
      6,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
    return '$firstChar$rest';
  }
}

/// ─── Wagt we baha formatlary ───────────────────────────────
class AppFormatters {
  AppFormatters._();

  static final _timeFormat = DateFormat('HH:mm');
  static final _dateFormat = DateFormat('dd.MM.yyyy');
  static final _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

  /// '14:35' — sagat:minut
  static String formatTime(DateTime dt) => _timeFormat.format(dt);

  /// '12.04.2025'
  static String formatDate(DateTime dt) => _dateFormat.format(dt);

  /// '12.04.2025 14:35'
  static String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);

  /// Bahany formatla: '15.50'
  static String formatPrice(double price, [String currency = '']) {
    final raw = formatPriceRaw(price);
    return currency.isEmpty ? raw : '$raw $currency';
  }

  /// '15.50' — TMT belgisi ýok
  static String formatPriceRaw(double price) {
    if (price >= 100) return price.toStringAsFixed(1);
    return price.toStringAsFixed(2);
  }

  /// Duration -> 'HH:MM:SS' ýa-da 'MM:SS'
  static String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '${h.toString().padLeft(2, '0')}:$m:$s';
    return '$m:$s';
  }

  /// Şu gün ýa başga gün kontroly
  static bool isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  static bool isYesterday(DateTime dt) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day;
  }

  /// Smart date label
  static String smartDateLabel(DateTime dt) {
    if (isToday(dt)) return 'Şu gün';
    if (isYesterday(dt)) return 'Düýn';
    return formatDate(dt);
  }

  /// Sagat başlangyjy (00:00:00)
  static DateTime startOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Sagat soňy (23:59:59)
  static DateTime endOfDay(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);
}
