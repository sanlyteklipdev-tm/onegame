import 'package:isar/isar.dart';

part 'player_session_model.g.dart';

/// Sessiýanyň ýagdaýy
enum SessionStatus {
  /// Oýun dowam edýär
  active,

  /// Tamamlandy, hasaplanyp gutaryldy
  finished,
}

/// Müşderi sessiýasy
///
/// BAHALANDYRMA ÝAGDAÝY:
///   - [accumulatedCost]: Soňky checkpointden öňki jemlenip gelýän baha
///   - [lastCheckpointTime]: Sonky checkpoint wagty
///   - Real-time baha = accumulatedCost + (häzir - lastCheckpointTime) * rate / activeCount
///
/// CHECKPOINT DÖREDILÝÄN HALATLAR:
///   1. Täze müşderi goşulýar
///   2. Müşderi STOP edilýär
///   (Her iki ýagdaýda ähli aktiw sessiýalaryň hasaby täzelenýär)
@collection
class PlayerSessionModel {
  Id id = Isar.autoIncrement;

  /// Bu sessiýanyň hansy stola degişlidigi
  @Index()
  late int tableId;

  /// Müşderiniň ady
  late String playerName;

  /// Awtomatiki ýasalan özboluşly kod: 'FeWdj32'
  @Index(unique: true)
  late String sessionCode;

  /// Sessiýa başlan wagt
  late DateTime startTime;

  /// Sessiýa tamamlanan wagt (null = heniz dowam edýär)
  DateTime? endTime;

  /// Ýagdaý
  @enumerated
  late SessionStatus status;

  // ─── Dinamiki Bahalandyrma Ýagdaýy ──────────────────────

  /// Soňky checkpoint wagyna çenli toplanana baha (TMT)
  late double accumulatedCost;

  /// Soňky checkpoint wagty (başlangyjda = startTime)
  late DateTime lastCheckpointTime;

  /// Jemi tölenmeli baha (tamamlananda bellenýär)
  late double totalPrice;

  /// Müşderiniň ID-sy (CustomerModel)
  int? customerId;

  /// Skidka göterimi (%)
  late double discountPercentage;

  /// Bildiriş ugratmaly wagt (minutda). Null bolsa bildiriş gelmez.
  int? reminderMinutes;

  PlayerSessionModel();

  factory PlayerSessionModel.create({
    required int tableId,
    required String playerName,
    required String sessionCode,
    int? reminderMinutes,
  }) {
    final now = DateTime.now();
    return PlayerSessionModel()
      ..tableId = tableId
      ..playerName = playerName
      ..sessionCode = sessionCode
      ..startTime = now
      ..endTime = null
      ..status = SessionStatus.active
      ..accumulatedCost = 0.0
      ..lastCheckpointTime = now
      ..totalPrice = 0.0
      ..customerId = null
      ..discountPercentage = 0.0
      ..reminderMinutes = reminderMinutes;
  }

  bool get isActive => status == SessionStatus.active;
  bool get isFinished => status == SessionStatus.finished;

  /// Sessiýa dowamlylygy
  @ignore
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  @override
  String toString() =>
      'PlayerSession(id=$id, name=$playerName, code=$sessionCode, status=$status)';
}
