import 'package:isar/isar.dart';

import '../../models/employee_model.dart';
import '../../remote/pg_stream.dart';
import '../../remote/postgres_service.dart';
import '../employee_repository.dart';

const _select = '''
SELECT id, name, phone, category, created_at
FROM employees
''';

EmployeeCategory _categoryFrom(String value) => switch (value) {
  'B' => EmployeeCategory.b,
  'C' => EmployeeCategory.c,
  _ => EmployeeCategory.a,
};

EmployeeModel _map(Map<String, dynamic> row) => EmployeeModel()
  ..id = row['id'] as int
  ..name = row['name'] as String
  ..phone = row['phone'] as String?
  ..category = _categoryFrom((row['category'] as String).trim())
  ..createdAt = (row['created_at'] as DateTime).toLocal();

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
            INSERT INTO employees (name, phone, category)
            VALUES (@name, @phone, @category)
            RETURNING id
            '''
          : '''
            UPDATE employees
            SET name = @name, phone = @phone, category = @category
            WHERE id = @id
            RETURNING id
            ''',
      parameters: {
        'name': employee.name,
        'phone': employee.phone,
        'category': employee.category.label,
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
