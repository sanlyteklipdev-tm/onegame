import 'package:isar/isar.dart';

import '../local/isar_service.dart';
import '../models/player_session_model.dart';
import '../models/table_model.dart';
import '../models/history_log_model.dart';
import '../../core/utils/price_calculator.dart';

/// Sessiýa repository interfeýsi
abstract class SessionRepository {
  Future<List<PlayerSessionModel>> getActiveSessions(int tableId);
  Future<PlayerSessionModel?> getSessionById(int sessionId);
  Future<void> setReminderMinutes(int sessionId, int? minutes);
  Future<List<PlayerSessionModel>> getFinishedSessions(
    int tableId, {
    int limit,
  });
  Stream<List<PlayerSessionModel>> watchActiveSessions(int tableId);
  Stream<List<PlayerSessionModel>> watchFinishedSessions(int tableId, {int limit});
  Future<PlayerSessionModel> startSession(PlayerSessionModel session);
  Future<void> stopSession({
    required int sessionId,
    required int tableId,
    required String tableName,
    required double pricePerHour,
    double discountPercentage = 0.0,
    double discountAmount = 0.0,
  });
  Future<HistoryLogModel> stopTable({
    required int tableId,
    required String tableName,
    required double pricePerHour,
    required String payerName,
  });
  Future<List<HistoryLogModel>> getHistory({
    required DateTime from,
    required DateTime to,
    int? tableId,
  });
  Stream<List<HistoryLogModel>> watchTableHistory(int tableId, {int limit});
  Future<double> getTotalRevenue({DateTime? from, DateTime? to, int? tableId});

  /// Bellenilen stolda, berlen wagt aralygynda (üstünden geçýän) oýnan
  /// ähli oýunçylaryň sessiýalaryny getirýär (at, wagt we baha üçin).
  /// Taryh ýazgysyna basylanda "Şol wagt bilelikde oýnan oýunçylar"
  /// sanawyny (wagt/baha bilen) görkezmek üçin ulanylýar.
  Future<List<PlayerSessionModel>> getPlayersPlayedInWindow({
    required int tableId,
    required DateTime start,
    required DateTime end,
  });
}

/// Isar-a esaslanýan implementasiýa
///
/// BAHALANDYRMA ALGORITMI:
/// 1. [startSession]: Täze sessiýa goşulyşanda, soňky checkpointten şu wagta
///    çenli ähli aktiw sessiýalaryň hasabyny täzeläp, checkpointi häzirki wagt bilen täzelýär.
/// 2. [stopSession]: Saklanylanda hem şol güýji ulanýar. Soňra sessiýany tamamlap,
///    taryh ýazgysy döredýär we stoly ýagdaýyny barlaýar.
class IsarSessionRepository implements SessionRepository {
  Isar get _db => IsarService.isar;

  @override
  Future<List<PlayerSessionModel>> getActiveSessions(int tableId) async {
    return _db.playerSessionModels
        .filter()
        .tableIdEqualTo(tableId)
        .statusEqualTo(SessionStatus.active)
        .sortByStartTime()
        .findAll();
  }

  @override
  Future<PlayerSessionModel?> getSessionById(int sessionId) =>
      _db.playerSessionModels.get(sessionId);

  @override
  Future<void> setReminderMinutes(int sessionId, int? minutes) async {
    await _db.writeTxn(() async {
      final session = await _db.playerSessionModels.get(sessionId);
      if (session == null) return;
      session.reminderMinutes = minutes;
      await _db.playerSessionModels.put(session);
    });
  }

  @override
  Future<List<PlayerSessionModel>> getFinishedSessions(
    int tableId, {
    int limit = 20,
  }) async {
    return _db.playerSessionModels
        .filter()
        .tableIdEqualTo(tableId)
        .statusEqualTo(SessionStatus.finished)
        .sortByEndTimeDesc()
        .limit(limit)
        .findAll();
  }

  @override
  Stream<List<PlayerSessionModel>> watchActiveSessions(int tableId) {
    return _db.playerSessionModels
        .filter()
        .tableIdEqualTo(tableId)
        .statusEqualTo(SessionStatus.active)
        .sortByStartTime()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<PlayerSessionModel>> watchFinishedSessions(
    int tableId, {
    int limit = 15,
  }) {
    return _db.playerSessionModels
        .filter()
        .tableIdEqualTo(tableId)
        .statusEqualTo(SessionStatus.finished)
        .sortByEndTimeDesc()
        .limit(limit)
        .watch(fireImmediately: true);
  }

  /// Täze sessiýa başlatmak
  ///
  /// ALGORITM:
  /// 1. Ähli aktiw sessiýalary al
  /// 2. Her biri üçin [lastCheckpointTime → häzir] aralygyndaky hasaby accumulate et
  /// 3. Ähli sessiýalaryň [lastCheckpointTime] = häzir belläp täzele
  /// 4. Täze sessiýany goş — indi has köp oýunçy bar, baha bölünýär
  @override
  Future<PlayerSessionModel> startSession(PlayerSessionModel session) async {
    await _db.writeTxn(() async {
      final now = DateTime.now();

      // 1. Şu wagtky aktiw sessiýalary al (täze sessiýa heniz goşulmady)
      final existing = await _db.playerSessionModels
          .filter()
          .tableIdEqualTo(session.tableId)
          .statusEqualTo(SessionStatus.active)
          .findAll();

      // 2. Stoluň bahasy gerek, ýöne repositoryde table ýok...
      //    Checkpointi täzelemek üçin stoly okamaly
      if (existing.isNotEmpty) {
        final table = await _db.tableModels.get(session.tableId);
        if (table != null) {
          final playerCount = existing.length;
          for (final s in existing) {
            final elapsed = now.difference(s.lastCheckpointTime);
            final delta = PriceCalculator.segmentCostPerPlayer(
              pricePerHour: table.pricePerHour,
              durationSeconds: elapsed.inMilliseconds / 1000.0,
              playerCount: playerCount,
            );
            s.accumulatedCost += delta;
            s.lastCheckpointTime = now;
          }
          await _db.playerSessionModels.putAll(existing);
        }
      }

      // 3. Täze sessiýany goş
      session.lastCheckpointTime = now;
      session.startTime = now;
      final newId = await _db.playerSessionModels.put(session);
      session.id = newId;

      // 4. Stol ýagdaýyny 'active' et
      final table = await _db.tableModels.get(session.tableId);
      if (table != null && table.status != TableStatus.active) {
        table.status = TableStatus.active;
        await _db.tableModels.put(table);
      }
    });

    return session;
  }

  /// Sessiýany tamamlamak
  ///
  /// ALGORITM:
  /// 1. Ähli aktiw sessiýalary al (saklanýan sessiýa hem içinde)
  /// 2. Ähli sessiýalaryň soňky segmentini hesapla we accumulate et
  /// 3. Saklanylan sessiýany finished et, totalPrice belläp
  /// 4. Taryh ýazgysy döret
  /// 5. Stol ýagdaýyny barla (başga aktiw sessiýa galdymy?)
  @override
  Future<void> stopSession({
    required int sessionId,
    required int tableId,
    required String tableName,
    required double pricePerHour,
    double discountPercentage = 0.0,
    double discountAmount = 0.0,
  }) async {
    await _db.writeTxn(() async {
      final now = DateTime.now();

      // 1. Ähli aktiw sessiýalary al
      final allActive = await _db.playerSessionModels
          .filter()
          .tableIdEqualTo(tableId)
          .statusEqualTo(SessionStatus.active)
          .findAll();

      if (allActive.isEmpty) return;

      final playerCount = allActive.length;

      // 2. Ähli sessiýalaryň soňky segmentini hesapla
      for (final s in allActive) {
        final elapsed = now.difference(s.lastCheckpointTime);
        final delta = PriceCalculator.segmentCostPerPlayer(
          pricePerHour: pricePerHour,
          durationSeconds: elapsed.inMilliseconds / 1000.0,
          playerCount: playerCount,
        );
        s.accumulatedCost += delta;
        s.lastCheckpointTime = now;
      }

      // 3. Saklanylan sessiýany tap we tamamla
      final target = allActive.firstWhere((s) => s.id == sessionId);
      target.status = SessionStatus.finished;
      target.endTime = now;
      // Skidka ulanylýar
      final rawCost = target.accumulatedCost;
      final effDiscount = discountPercentage > 0 ? discountPercentage : target.discountPercentage;
      final effDiscountAmount = discountAmount > 0 ? discountAmount : (rawCost * effDiscount / 100.0);
      target.totalPrice = rawCost - effDiscountAmount;

      // Galanlaryň checkpointini täzele (indi az adam bar)
      await _db.playerSessionModels.putAll(allActive);

      // 4. Taryh ýazgysy döret
      final log = HistoryLogModel.fromSession(
        tableId: tableId,
        tableName: tableName,
        sessionId: sessionId,
        sessionCode: target.sessionCode,
        playerName: target.playerName,
        startTime: target.startTime,
        endTime: now,
        totalPrice: target.totalPrice,
        discountPercentage: effDiscount > 0 ? effDiscount : null,
        discountAmount: effDiscountAmount > 0 ? effDiscountAmount : null,
      );
      await _db.historyLogModels.put(log);

      // 5. Stol ýagdaýyny barla
      final remainingActive = allActive
          .where((s) => s.id != sessionId)
          .toList();
      if (remainingActive.isEmpty) {
        final table = await _db.tableModels.get(tableId);
        if (table != null) {
          table.status = TableStatus.available;
          await _db.tableModels.put(table);
        }
      }
    });
  }

  @override
  Future<HistoryLogModel> stopTable({
    required int tableId,
    required String tableName,
    required double pricePerHour,
    required String payerName,
  }) async {
    return await _db.writeTxn(() async {
      final now = DateTime.now();

      final allActive = await _db.playerSessionModels
          .filter()
          .tableIdEqualTo(tableId)
          .statusEqualTo(SessionStatus.active)
          .findAll();

      if (allActive.isEmpty) {
        throw Exception("Aktiw sessiýa tapylmady");
      }

      final playerCount = allActive.length;
      double tableTotalCost = 0;
      DateTime earliestStart = now;

      // Hemmesiniň akumulýasiýasyny çykar
      double totalDiscountAmount = 0;
      for (final s in allActive) {
        final elapsed = now.difference(s.lastCheckpointTime);
        final delta = PriceCalculator.segmentCostPerPlayer(
          pricePerHour: pricePerHour,
          durationSeconds: elapsed.inMilliseconds / 1000.0,
          playerCount: playerCount,
        );
        s.accumulatedCost += delta;
        s.lastCheckpointTime = now;
        s.status = SessionStatus.finished;
        s.endTime = now;
        
        // Skidka hasapla
        final discAmount = s.accumulatedCost * s.discountPercentage / 100.0;
        s.totalPrice = s.accumulatedCost - discAmount;
        
        totalDiscountAmount += discAmount;
        tableTotalCost += s.totalPrice;
        if (s.startTime.isBefore(earliestStart)) {
          earliestStart = s.startTime;
        }
      }

      await _db.playerSessionModels.putAll(allActive);

      // Ýeke taryh ýazgysy
      final log = HistoryLogModel.fromSession(
        tableId: tableId,
        tableName: tableName,
        sessionId: 0,
        sessionCode: 'TOPLUMLAÝYN',
        playerName: payerName,
        startTime: earliestStart,
        endTime: now,
        totalPrice: tableTotalCost,
        discountAmount: totalDiscountAmount,
      );
      await _db.historyLogModels.put(log);

      // Stoly boşat
      final table = await _db.tableModels.get(tableId);
      if (table != null) {
        table.status = TableStatus.available;
        await _db.tableModels.put(table);
      }

      return log;
    });
  }

  @override
  Future<List<HistoryLogModel>> getHistory({
    required DateTime from,
    required DateTime to,
    int? tableId,
  }) async {
    if (tableId != null) {
      return _db.historyLogModels
          .filter()
          .tableIdEqualTo(tableId)
          .startTimeBetween(from, to)
          .sortByStartTimeDesc()
          .findAll();
    }
    return _db.historyLogModels
        .filter()
        .startTimeBetween(from, to)
        .sortByStartTimeDesc()
        .findAll();
  }

  @override
  Stream<List<HistoryLogModel>> watchTableHistory(
    int tableId, {
    int limit = 15,
  }) {
    return _db.historyLogModels
        .filter()
        .tableIdEqualTo(tableId)
        .sortByCreatedAtDesc()
        .limit(limit)
        .watch(fireImmediately: true);
  }

  @override
  Future<double> getTotalRevenue({
    DateTime? from,
    DateTime? to,
    int? tableId,
  }) async {
    List<HistoryLogModel> logs;

    if (from != null && to != null && tableId != null) {
      logs = await _db.historyLogModels
          .filter()
          .tableIdEqualTo(tableId)
          .startTimeBetween(from, to)
          .findAll();
    } else if (from != null && to != null) {
      logs = await _db.historyLogModels
          .filter()
          .startTimeBetween(from, to)
          .findAll();
    } else if (tableId != null) {
      logs = await _db.historyLogModels
          .filter()
          .tableIdEqualTo(tableId)
          .findAll();
    } else {
      logs = await _db.historyLogModels.where().findAll();
    }

    return logs.fold<double>(0.0, (sum, log) => sum + log.totalPrice);
  }

  @override
  Future<List<PlayerSessionModel>> getPlayersPlayedInWindow({
    required int tableId,
    required DateTime start,
    required DateTime end,
  }) async {
    // PlayerSessionModel-lar tamamlanandan soň hem bazada galýar (diňe
    // status=finished bolýar), şonuň üçin şu ýerden sanaw dikeldip bolýar.
    final sessions = await _db.playerSessionModels
        .filter()
        .tableIdEqualTo(tableId)
        .startTimeLessThan(end, include: true)
        .group(
          (q) => q.endTimeIsNull().or().endTimeGreaterThan(start, include: true),
        )
        .findAll();

    sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
    return sessions;
  }
}