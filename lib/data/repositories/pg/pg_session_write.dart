import 'package:postgres/postgres.dart';

import '../../../core/utils/price_calculator.dart';
import '../../models/history_log_model.dart';
import '../../models/player_session_model.dart';
import 'pg_session_mapper.dart';

Future<Result> _tx(
  TxSession tx,
  String sql, [
  Map<String, Object?> params = const {},
]) =>
    params.isEmpty
        ? tx.execute(sql)
        : tx.execute(Sql.named(sql), parameters: params);

/// Stoluň aktiw sessiýalarynyň hasabyny [now] pursadyna çenli täzeleýär
/// (checkpoint). Isar wersiýasyndaky algoritmiň dogry gaýtalanmasy.
Future<List<PlayerSessionModel>> _advanceCheckpoints(
  TxSession tx,
  int tableId,
  double pricePerHour,
  DateTime now,
) async {
  final res = await _tx(
    tx,
    "$sessionSelect WHERE table_id = @t AND status = 'active'",
    {'t': tableId},
  );
  final sessions = res.map((r) => mapSession(r.toColumnMap())).toList();
  if (sessions.isEmpty) return sessions;

  final playerCount = sessions.length;
  for (final s in sessions) {
    final elapsed = now.difference(s.lastCheckpointTime);
    s.accumulatedCost += PriceCalculator.segmentCostPerPlayer(
      pricePerHour: pricePerHour,
      durationSeconds: elapsed.inMilliseconds / 1000.0,
      playerCount: playerCount,
    );
    s.lastCheckpointTime = now;

    await _tx(
      tx,
      '''
      UPDATE player_sessions
      SET accumulated_cost = @cost, last_checkpoint_time = @cp
      WHERE id = @id
      ''',
      {'cost': s.accumulatedCost, 'cp': now, 'id': s.id},
    );
  }
  return sessions;
}

Future<double> _tablePrice(TxSession tx, int tableId) async {
  final res = await _tx(
    tx,
    'SELECT price_per_hour::float8 AS p FROM game_tables WHERE id = @id',
    {'id': tableId},
  );
  if (res.isEmpty) return 0;
  return (res.first.toColumnMap()['p'] as num).toDouble();
}

/// Täze oýunçy goşmak
Future<PlayerSessionModel> startSessionTx(
  TxSession tx,
  PlayerSessionModel session,
) async {
  final now = DateTime.now();
  final price = await _tablePrice(tx, session.tableId);
  await _advanceCheckpoints(tx, session.tableId, price, now);

  final res = await _tx(
    tx,
    '''
    INSERT INTO player_sessions
      (table_id, player_name, session_code, start_time, status,
       accumulated_cost, last_checkpoint_time, total_price,
       customer_id, discount_percentage, reminder_minutes)
    VALUES (@tableId, @name, @code, @start, 'active',
            0, @start, 0, @customerId, @discount, @reminder)
    RETURNING id
    ''',
    {
      'tableId': session.tableId,
      'name': session.playerName,
      'code': session.sessionCode,
      'start': now,
      'customerId': session.customerId,
      'discount': session.discountPercentage,
      'reminder': session.reminderMinutes,
    },
  );

  session
    ..id = res.first.toColumnMap()['id'] as int
    ..startTime = now
    ..lastCheckpointTime = now;

  await _tx(
    tx,
    "UPDATE game_tables SET status = 'active' WHERE id = @id",
    {'id': session.tableId},
  );
  return session;
}

Future<void> _insertHistory(TxSession tx, HistoryLogModel log) async {
  await _tx(
    tx,
    '''
    INSERT INTO history_logs
      (table_id, table_name, session_id, session_code, player_name,
       start_time, end_time, total_price, discount_percentage,
       discount_amount, created_at)
    VALUES (@tableId, @tableName, @sessionId, @code, @player,
            @start, @end, @total, @discPct, @discAmt, @createdAt)
    ''',
    {
      'tableId': log.tableId,
      'tableName': log.tableName,
      'sessionId': log.sessionId,
      'code': log.sessionCode,
      'player': log.playerName,
      'start': log.startTime,
      'end': log.endTime,
      'total': log.totalPrice,
      'discPct': log.discountPercentage,
      'discAmt': log.discountAmount,
      'createdAt': log.createdAt,
    },
  );
}

/// Bir oýunçyny saklamak
Future<void> stopSessionTx(
  TxSession tx, {
  required int sessionId,
  required int tableId,
  required String tableName,
  required double pricePerHour,
  required double discountPercentage,
  required double discountAmount,
}) async {
  final now = DateTime.now();
  final active = await _advanceCheckpoints(tx, tableId, pricePerHour, now);
  if (active.isEmpty) return;

  final target = active.firstWhere((s) => s.id == sessionId);
  final rawCost = target.accumulatedCost;
  final effDiscount =
      discountPercentage > 0 ? discountPercentage : target.discountPercentage;
  final effAmount =
      discountAmount > 0 ? discountAmount : rawCost * effDiscount / 100.0;
  final total = rawCost - effAmount;

  await _tx(
    tx,
    '''
    UPDATE player_sessions
    SET status = 'finished', end_time = @end, total_price = @total
    WHERE id = @id
    ''',
    {'end': now, 'total': total, 'id': sessionId},
  );

  await _insertHistory(
    tx,
    HistoryLogModel.fromSession(
      tableId: tableId,
      tableName: tableName,
      sessionId: sessionId,
      sessionCode: target.sessionCode,
      playerName: target.playerName,
      startTime: target.startTime,
      endTime: now,
      totalPrice: total,
      discountPercentage: effDiscount > 0 ? effDiscount : null,
      discountAmount: effAmount > 0 ? effAmount : null,
    ),
  );

  if (active.length == 1) {
    await _tx(
      tx,
      "UPDATE game_tables SET status = 'available' WHERE id = @id",
      {'id': tableId},
    );
  }
}

/// Stoly doly ýapmak — ähli oýunçylar bir çekde
Future<HistoryLogModel> stopTableTx(
  TxSession tx, {
  required int tableId,
  required String tableName,
  required double pricePerHour,
  required String payerName,
}) async {
  final now = DateTime.now();
  final active = await _advanceCheckpoints(tx, tableId, pricePerHour, now);
  if (active.isEmpty) throw Exception('Aktiw sessiýa tapylmady');

  var tableTotal = 0.0;
  var totalDiscount = 0.0;
  var earliestStart = now;

  for (final s in active) {
    final discAmount = s.accumulatedCost * s.discountPercentage / 100.0;
    final total = s.accumulatedCost - discAmount;
    totalDiscount += discAmount;
    tableTotal += total;
    if (s.startTime.isBefore(earliestStart)) earliestStart = s.startTime;

    await _tx(
      tx,
      '''
      UPDATE player_sessions
      SET status = 'finished', end_time = @end, total_price = @total
      WHERE id = @id
      ''',
      {'end': now, 'total': total, 'id': s.id},
    );
  }

  final log = HistoryLogModel.fromSession(
    tableId: tableId,
    tableName: tableName,
    sessionId: 0,
    sessionCode: 'TOPLUMLAÝYN',
    playerName: payerName,
    startTime: earliestStart,
    endTime: now,
    totalPrice: tableTotal,
    discountAmount: totalDiscount,
  );
  await _insertHistory(tx, log);

  await _tx(
    tx,
    "UPDATE game_tables SET status = 'available' WHERE id = @id",
    {'id': tableId},
  );
  return log;
}
