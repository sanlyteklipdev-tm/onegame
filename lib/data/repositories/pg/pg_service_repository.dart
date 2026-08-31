import 'package:isar/isar.dart';

import '../../../core/services/device_name_service.dart';
import '../../models/service_model.dart';
import '../../remote/pg_stream.dart';
import '../../remote/postgres_service.dart';
import '../service_repository.dart';

const _select = '''
SELECT id, name, price::float8 AS price, created_at, device_name
FROM services
''';

ServiceModel _map(Map<String, dynamic> row) => ServiceModel()
  ..id = row['id'] as int
  ..name = row['name'] as String
  ..price = (row['price'] as num).toDouble()
  ..createdAt = (row['created_at'] as DateTime).toLocal()
  ..deviceName = row['device_name'] as String?;

class PgServiceRepository implements ServiceRepository {
  @override
  Stream<List<ServiceModel>> watchAll() => pollingStream(getAll);

  @override
  Future<List<ServiceModel>> getAll() async {
    final res = await PostgresService.query('$_select ORDER BY name');
    return res.map((r) => _map(r.toColumnMap())).toList();
  }

  @override
  Future<ServiceModel?> getById(int id) async {
    final res = await PostgresService.query(
      '$_select WHERE id = @id',
      parameters: {'id': id},
    );
    if (res.isEmpty) return null;
    return _map(res.first.toColumnMap());
  }

  @override
  Future<int> save(ServiceModel service) async {
    final isNew = service.id == Isar.autoIncrement;

    final res = await PostgresService.query(
      isNew
          ? '''
            INSERT INTO services (name, price, device_name)
            VALUES (@name, @price, @device)
            RETURNING id
            '''
          : '''
            UPDATE services
            SET name = @name, price = @price
            WHERE id = @id
            RETURNING id
            ''',
      parameters: {
        'name': service.name,
        'price': service.price,
        if (isNew) 'device': DeviceNameService.current,
        if (!isNew) 'id': service.id,
      },
    );

    final id = res.first.toColumnMap()['id'] as int;
    service.id = id;
    return id;
  }

  @override
  Future<void> delete(int id) async {
    await PostgresService.query(
      'DELETE FROM services WHERE id = @id',
      parameters: {'id': id},
    );
  }
}
