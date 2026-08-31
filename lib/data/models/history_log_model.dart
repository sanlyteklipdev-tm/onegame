import 'package:isar/isar.dart';

part 'history_log_model.g.dart';

/// Tamamlanan sessiýanyň taryh ýazgysy
///
/// Hasabat we çek çap üçin ulanylýar.
/// PlayerSession tamamlananda awtomatiki döredilýär.
@collection
class HistoryLogModel {
  Id id = Isar.autoIncrement;

  // ─── Stol maglumatlary ──────────────────────────────────
  @Index()
  late int tableId;

  late String tableName;

  // ─── Sessiýa maglumatlary ────────────────────────────────
  late int sessionId;
  late String sessionCode;
  late String playerName;

  // ─── Wagt maglumatlary ──────────────────────────────────
  @Index()
  late DateTime startTime;

  late DateTime endTime;

  // ─── Maliýe maglumatlary ─────────────────────────────────
  late double totalPrice;

  /// Skidka göterimi (%)
  double? discountPercentage;

  /// Skidka edilen mukdar (TMT)
  double? discountAmount;

  /// Ýazgy döredilen wagt
  @Index()
  late DateTime createdAt;

  /// Haýsy enjamdan goşuldy. Köne ýazgylarda boş.
  String? deviceName;

  HistoryLogModel();

  factory HistoryLogModel.fromSession({
    required int tableId,
    required String tableName,
    required int sessionId,
    required String sessionCode,
    required String playerName,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
    double? discountPercentage,
    double? discountAmount,
  }) => HistoryLogModel()
    ..tableId = tableId
    ..tableName = tableName
    ..sessionId = sessionId
    ..sessionCode = sessionCode
    ..playerName = playerName
    ..startTime = startTime
    ..endTime = endTime
    ..totalPrice = totalPrice
    ..discountPercentage = discountPercentage
    ..discountAmount = discountAmount
    ..createdAt = DateTime.now();

  /// Oýnalan dowamlylygy
  @ignore
  Duration get duration => endTime.difference(startTime);

  @override
  String toString() =>
      'HistoryLog(code=$sessionCode, player=$playerName, price=$totalPrice TMT)';
}
