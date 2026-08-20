import 'package:isar/isar.dart';

import '../local/isar_service.dart';
import '../models/customer_model.dart';

/// Müşderi repository interfeýsi
abstract class CustomerRepository {
  Stream<List<CustomerModel>> watchAll();
  Future<List<CustomerModel>> getAll();
  Future<CustomerModel?> getById(int id);
  Future<int> save(CustomerModel customer);
  Future<void> delete(int id);
}

/// Isar implementasiýa
class IsarCustomerRepository implements CustomerRepository {
  Isar get _db => IsarService.isar;

  @override
  Stream<List<CustomerModel>> watchAll() {
    return _db.customerModels
        .where()
        .sortByName()
        .watch(fireImmediately: true);
  }

  @override
  Future<List<CustomerModel>> getAll() {
    return _db.customerModels.where().sortByName().findAll();
  }

  @override
  Future<CustomerModel?> getById(int id) {
    return _db.customerModels.get(id);
  }

  @override
  Future<int> save(CustomerModel customer) async {
    return await _db.writeTxn(() async {
      return await _db.customerModels.put(customer);
    });
  }

  @override
  Future<void> delete(int id) async {
    await _db.writeTxn(() async {
      await _db.customerModels.delete(id);
    });
  }
}
