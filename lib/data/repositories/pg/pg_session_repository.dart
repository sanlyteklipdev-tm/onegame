import '../../models/history_log_model.dart';
import '../../models/player_session_model.dart';
import '../../remote/pg_stream.dart';
import '../../remote/postgres_service.dart';
import '../session_repository.dart';
import 'pg_session_mapper.dart';
import 'pg_session_write.dart';

class PgSessionRepository implements SessionRepository {
  // ── Okamak ────────────────────────────────────────────────

  @override
  Future<List<PlayerSessionModel>> getActiveSessions(int tableId) async {
    final res = await PostgresService.query(
      "$sessionSelect WHERE table_id = @t AND status = 'active' "
      'ORDER BY start_time',
      parameters: {'t': tableId},
    );
    return res.map((r) => mapSession(r.toColumnMap())).toList();
  }

  @override
  Future<PlayerSessionModel?> getSessionById(int sessionId) async {
    final res = await PostgresService.query(
      '$sessionSelect WHERE id = @id',
      parameters: {'id': sessionId},
    );
    if (res.isEmpty) return null;
    return mapSession(res.first.toColumnMap());
  }

  @override
  Future<void> setReminderMinutes(int sessionId, int? minutes) async {
    await PostgresService.query(
      'UPDATE player_sessions SET reminder_minutes = @m WHERE id = @id',
      parameters: {'m': minutes, 'id': sessionId},
    );
  }

  @override
  Future<List<PlayerSessionModel>> getFinishedSessions(
    int tableId, {
    int limit = 20,
  }) async {
    final res = await PostgresService.query(
      "$sessionSelect WHERE table_id = @t AND status = 'finished' "
      'ORDER BY end_time DESC LIMIT @lim',
      parameters: {'t': tableId, 'lim': limit},
    );
    return res.map((r) => mapSession(r.toColumnMap())).toList();
  }

  @override
  Stream<List<PlayerSessionModel>> watchActiveSessions(int tableId) =>
      pollingStream(() => getActiveSessions(tableId));

  @override
  Stream<List<PlayerSessionModel>> watchFinishedSessions(
    int tableId, {
    int limit = 15,
  }) =>
      pollingStream(() => getFinishedSessions(tableId, limit: limit));

  @override
  Stream<List<HistoryLogModel>> watchTableHistory(
    int tableId, {
    int limit = 15,
  }) =>
      pollingStream(() async {
        final res = await PostgresService.query(
          '$historySelect WHERE table_id = @t '
          'ORDER BY created_at DESC LIMIT @lim',
          parameters: {'t': tableId, 'lim': limit},
        );
        return res.map((r) => mapHistory(r.toColumnMap())).toList();
      });

  @override
  Future<List<HistoryLogModel>> getHistory({
    required DateTime from,
    required DateTime to,
    int? tableId,
  }) async {
    final res = await PostgresService.query(
      '''
      $historySelect
      WHERE start_time BETWEEN @from AND @to
        AND (@tableId::bigint IS NULL OR table_id = @tableId::bigint)
      ORDER BY start_time DESC
      ''',
      parameters: {'from': from, 'to': to, 'tableId': tableId},
    );
    return res.map((r) => mapHistory(r.toColumnMap())).toList();
  }

  @override
  Future<double> getTotalRevenue({
    DateTime? from,
    DateTime? to,
    int? tableId,
  }) async {
    // Jemi bazanyň özünde hasaplanýar — ähli ýazgylary çekmek gerek däl
    final res = await PostgresService.query(
      '''
      SELECT COALESCE(SUM(total_price), 0)::float8 AS revenue
      FROM history_logs
      WHERE (@from::timestamptz IS NULL OR start_time >= @from::timestamptz)
        AND (@to::timestamptz   IS NULL OR start_time <= @to::timestamptz)
        AND (@tableId::bigint   IS NULL OR table_id = @tableId::bigint)
      ''',
      parameters: {'from': from, 'to': to, 'tableId': tableId},
    );
    return (res.first.toColumnMap()['revenue'] as num).toDouble();
  }

  @override
  Future<List<PlayerSessionModel>> getPlayersPlayedInWindow({
    required int tableId,
    required DateTime start,
    required DateTime end,
  }) async {
    final res = await PostgresService.query(
      '''
      $sessionSelect
      WHERE table_id = @t
        AND start_time <= @end
        AND (end_time IS NULL OR end_time >= @start)
      ORDER BY start_time
      ''',
      parameters: {'t': tableId, 'start': start, 'end': end},
    );
    return res.map((r) => mapSession(r.toColumnMap())).toList();
  }

  // ── Ýazmak (tranzaksiýada) ────────────────────────────────

  @override
  Future<PlayerSessionModel> startSession(PlayerSessionModel session) =>
      PostgresService.transaction((tx) => startSessionTx(tx, session));

  @override
  Future<void> stopSession({
    required int sessionId,
    required int tableId,
    required String tableName,
    required double pricePerHour,
    double discountPercentage = 0.0,
    double discountAmount = 0.0,
  }) =>
      PostgresService.transaction(
        (tx) => stopSessionTx(
          tx,
          sessionId: sessionId,
          tableId: tableId,
          tableName: tableName,
          pricePerHour: pricePerHour,
          discountPercentage: discountPercentage,
          discountAmount: discountAmount,
        ),
      );

  @override
  Future<HistoryLogModel> stopTable({
    required int tableId,
    required String tableName,
    required double pricePerHour,
    required String payerName,
  }) =>
      PostgresService.transaction(
        (tx) => stopTableTx(
          tx,
          tableId: tableId,
          tableName: tableName,
          pricePerHour: pricePerHour,
          payerName: payerName,
        ),
      );
}
