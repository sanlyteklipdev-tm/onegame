import 'package:isar/isar.dart';

import '../../../core/services/device_name_service.dart';
import '../../models/customer_model.dart';
import '../../remote/pg_stream.dart';
import '../../remote/postgres_service.dart';
import '../customer_repository.dart';

/// NUMERIC sütünler `::float8` bilen alynýar — şonda drajwer olary
/// göni `double` edip berýär, setire öwrülmeýär.
const _select = '''
SELECT id, name, discount_percentage::float8 AS discount_percentage,
       phone, category, created_at, device_name
FROM customers
''';

CustomerModel _map(Map<String, dynamic> row) => CustomerModel()
  ..id = row['id'] as int
  ..name = row['name'] as String
  ..discountPercentage = (row['discount_percentage'] as num).toDouble()
  ..phone = row['phone'] as String?
  ..category = CustomerCategoryX.fromDb(row['category'] as String)
  ..createdAt = (row['created_at'] as DateTime).toLocal()
  ..deviceName = row['device_name'] as String?;

class PgCustomerRepository implements CustomerRepository {
  @override
  Stream<List<CustomerModel>> watchAll() => pollingStream(getAll);

  @override
  Future<List<CustomerModel>> getAll() async {
    final res = await PostgresService.query('$_select ORDER BY name');
    return res.map((r) => _map(r.toColumnMap())).toList();
  }

  @override
  Future<CustomerModel?> getById(int id) async {
    final res = await PostgresService.query(
      '$_select WHERE id = @id',
      parameters: {'id': id},
    );
    if (res.isEmpty) return null;
    return _map(res.first.toColumnMap());
  }

  @override
  Future<int> save(CustomerModel customer) async {
    final isNew = customer.id == Isar.autoIncrement;

    final res = await PostgresService.query(
      isNew
          ? '''
            INSERT INTO customers (name, discount_percentage, phone, category, device_name)
            VALUES (@name, @discount, @phone, @category, @device)
            RETURNING id
            '''
          : '''
            UPDATE customers
            SET name = @name,
                discount_percentage = @discount,
                phone = @phone,
                category = @category
            WHERE id = @id
            RETURNING id
            ''',
      parameters: {
        'name': customer.name,
        'discount': customer.discountPercentage,
        'phone': customer.phone,
        'category': customer.category.label,
        if (isNew) 'device': DeviceNameService.current,
        if (!isNew) 'id': customer.id,
      },
    );

    final id = res.first.toColumnMap()['id'] as int;
    customer.id = id;
    return id;
  }

  @override
  Future<void> delete(int id) async {
    await PostgresService.query(
      'DELETE FROM customers WHERE id = @id',
      parameters: {'id': id},
    );
  }
}
