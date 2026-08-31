import 'package:isar/isar.dart';

import '../../../core/services/device_name_service.dart';
import '../../models/employee_model.dart';
import '../../remote/pg_stream.dart';
import '../../remote/postgres_service.dart';
import '../employee_repository.dart';

const _select = '''
SELECT id, name, phone, job_position, employee_type, created_at, device_name
FROM employees
''';

EmployeeModel _map(Map<String, dynamic> row) => EmployeeModel()
  ..id = row['id'] as int
  ..name = row['name'] as String
  ..phone = row['phone'] as String?
  ..position = EmployeePositionX.fromDb(row['job_position'] as String)
  ..type = EmployeeTypeX.fromDb(row['employee_type'] as String)
  ..createdAt = (row['created_at'] as DateTime).toLocal()
  ..deviceName = row['device_name'] as String?;

class PgEmployeeRepository implements EmployeeRepository {
  @override
  Stream<List<EmployeeModel>> watchAll() => pollingStream(getAll);

  @override
  Future<List<EmployeeModel>> getAll() async {
    final res = await PostgresService.query('$_select ORDER BY name');
    return res.map((r) => _map(r.toColumnMap())).toList();
  }

  @override
  Future<EmployeeModel?> getById(int id) async {
    final res = await PostgresService.query(
      '$_select WHERE id = @id',
      parameters: {'id': id},
    );
    if (res.isEmpty) return null;
    return _map(res.first.toColumnMap());
  }

  @override
  Future<int> save(EmployeeModel employee) async {
    final isNew = employee.id == Isar.autoIncrement;

    final res = await PostgresService.query(
      isNew
          ? '''
            INSERT INTO employees (name, phone, job_position, employee_type,
                                   device_name)
            VALUES (@name, @phone, @position, @type, @device)
            RETURNING id
            '''
          : '''
            UPDATE employees
            SET name = @name, phone = @phone, job_position = @position,
                employee_type = @type
            WHERE id = @id
            RETURNING id
            ''',
      parameters: {
        'name': employee.name,
        'phone': employee.phone,
        'position': employee.position.dbValue,
        'type': employee.type.dbValue,
        if (isNew) 'device': DeviceNameService.current,
        if (!isNew) 'id': employee.id,
      },
    );

    final id = res.first.toColumnMap()['id'] as int;
    employee.id = id;
    return id;
  }

  @override
  Future<void> delete(int id) async {
    await PostgresService.query(
      'DELETE FROM employees WHERE id = @id',
      parameters: {'id': id},
    );
  }
}
