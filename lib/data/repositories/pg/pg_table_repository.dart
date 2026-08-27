import '../../models/table_model.dart';
import '../../remote/pg_stream.dart';
import '../../remote/postgres_service.dart';
import '../table_repository.dart';

const _select = '''
SELECT id, name, price_per_hour::float8 AS price_per_hour,
       max_users, status, created_at
FROM game_tables
''';

String _statusToDb(TableStatus s) =>
    s == TableStatus.active ? 'active' : 'available';

TableStatus _statusFromDb(String s) =>
    s == 'active' ? TableStatus.active : TableStatus.available;

TableModel _map(Map<String, dynamic> row) => TableModel()
  ..id = row['id'] as int
  ..name = row['name'] as String
  ..pricePerHour = (row['price_per_hour'] as num).toDouble()
  ..maxUsers = row['max_users'] as int?
  ..status = _statusFromDb(row['status'] as String)
  ..createdAt = (row['created_at'] as DateTime).toLocal();

class PgTableRepository implements TableRepository {
  @override
  Future<List<TableModel>> getAllTables() async {
    final res = await PostgresService.query('$_select ORDER BY name');
    return res.map((r) => _map(r.toColumnMap())).toList();
  }

  @override
  Future<TableModel?> getTableById(int id) async {
    final res = await PostgresService.query(
      '$_select WHERE id = @id',
      parameters: {'id': id},
    );
    if (res.isEmpty) return null;
    return _map(res.first.toColumnMap());
  }

  @override
  Stream<List<TableModel>> watchAllTables() => pollingStream(getAllTables);

  @override
  Future<TableModel> createTable(TableModel table) async {
    final res = await PostgresService.query(
      '''
      INSERT INTO game_tables (name, price_per_hour, max_users, status)
      VALUES (@name, @price, @maxUsers, @status)
      RETURNING id
      ''',
      parameters: {
        'name': table.name,
        'price': table.pricePerHour,
        'maxUsers': table.maxUsers,
        'status': _statusToDb(table.status),
      },
    );
    table.id = res.first.toColumnMap()['id'] as int;
    return table;
  }

  @override
  Future<void> updateTable(TableModel table) async {
    await PostgresService.query(
      '''
      UPDATE game_tables
      SET name = @name,
          price_per_hour = @price,
          max_users = @maxUsers,
          status = @status
      WHERE id = @id
      ''',
      parameters: {
        'id': table.id,
        'name': table.name,
        'price': table.pricePerHour,
        'maxUsers': table.maxUsers,
        'status': _statusToDb(table.status),
      },
    );
  }

  @override
  Future<void> deleteTable(int tableId) async {
    await PostgresService.query(
      'DELETE FROM game_tables WHERE id = @id',
      parameters: {'id': tableId},
    );
  }

  @override
  Future<void> updateTableStatus(int tableId, TableStatus status) async {
    await PostgresService.query(
      'UPDATE game_tables SET status = @status WHERE id = @id',
      parameters: {'id': tableId, 'status': _statusToDb(status)},
    );
  }
}
