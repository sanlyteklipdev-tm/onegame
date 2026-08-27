import 'package:isar/isar.dart';

import '../../models/reservation_model.dart';
import '../../remote/pg_stream.dart';
import '../../remote/postgres_service.dart';
import '../reservation_repository.dart';

const _select = '''
SELECT id, table_id, title, customer_id, employee_id,
       start_time, end_time, status, created_at
FROM reservations
''';

String _statusToDb(ReservationStatus s) =>
    s == ReservationStatus.started ? 'started' : 'pending';

ReservationStatus _statusFromDb(String s) =>
    s == 'started' ? ReservationStatus.started : ReservationStatus.pending;

ReservationModel _map(Map<String, dynamic> row) => ReservationModel()
  ..id = row['id'] as int
  ..tableId = row['table_id'] as int
  ..title = row['title'] as String
  ..customerId = row['customer_id'] as int?
  ..employeeId = row['employee_id'] as int?
  ..startTime = (row['start_time'] as DateTime).toLocal()
  ..endTime = (row['end_time'] as DateTime).toLocal()
  ..status = _statusFromDb(row['status'] as String)
  ..createdAt = (row['created_at'] as DateTime).toLocal();

class PgReservationRepository implements ReservationRepository {
  @override
  Stream<List<ReservationModel>> watchByDay(DateTime day) {
    final from = DateTime(day.year, day.month, day.day);
    final to = from.add(const Duration(days: 1));

    return pollingStream(() async {
      final res = await PostgresService.query(
        '''
        $_select
        WHERE start_time >= @from AND start_time < @to
        ORDER BY start_time
        ''',
        parameters: {'from': from, 'to': to},
      );
      return res.map((r) => _map(r.toColumnMap())).toList();
    });
  }

  @override
  Future<ReservationModel?> getById(int id) async {
    final res = await PostgresService.query(
      '$_select WHERE id = @id',
      parameters: {'id': id},
    );
    if (res.isEmpty) return null;
    return _map(res.first.toColumnMap());
  }

  @override
  Future<ReservationModel?> findOverlapping({
    required int tableId,
    required DateTime start,
    required DateTime end,
    int? excludeId,
  }) async {
    // Gabat gelme şerti bazadaky EXCLUDE çäklendirmesi bilen deň
    final res = await PostgresService.query(
      '''
      $_select
      WHERE table_id = @tableId
        AND start_time < @end
        AND end_time > @start
        AND (@excludeId::bigint IS NULL OR id <> @excludeId::bigint)
      LIMIT 1
      ''',
      parameters: {
        'tableId': tableId,
        'start': start,
        'end': end,
        'excludeId': excludeId,
      },
    );
    if (res.isEmpty) return null;
    return _map(res.first.toColumnMap());
  }

  @override
  Future<int> save(ReservationModel reservation) async {
    final isNew = reservation.id == Isar.autoIncrement;

    final res = await PostgresService.query(
      isNew
          ? '''
            INSERT INTO reservations
              (table_id, title, customer_id, employee_id,
               start_time, end_time, status)
            VALUES (@tableId, @title, @customerId, @employeeId,
                    @startTime, @endTime, @status)
            RETURNING id
            '''
          : '''
            UPDATE reservations
            SET table_id = @tableId,
                title = @title,
                customer_id = @customerId,
                employee_id = @employeeId,
                start_time = @startTime,
                end_time = @endTime,
                status = @status
            WHERE id = @id
            RETURNING id
            ''',
      parameters: {
        'tableId': reservation.tableId,
        'title': reservation.title,
        'customerId': reservation.customerId,
        'employeeId': reservation.employeeId,
        'startTime': reservation.startTime,
        'endTime': reservation.endTime,
        'status': _statusToDb(reservation.status),
        if (!isNew) 'id': reservation.id,
      },
    );

    final id = res.first.toColumnMap()['id'] as int;
    reservation.id = id;
    return id;
  }

  @override
  Future<void> markStarted(int id) async {
    await PostgresService.query(
      "UPDATE reservations SET status = 'started' WHERE id = @id",
      parameters: {'id': id},
    );
  }

  @override
  Future<void> delete(int id) async {
    await PostgresService.query(
      'DELETE FROM reservations WHERE id = @id',
      parameters: {'id': id},
    );
  }
}
