import 'package:isar/isar.dart';

import '../local/isar_service.dart';
import '../models/employee_model.dart';

/// Işgär repository interfeýsi
abstract class EmployeeRepository {
  Stream<List<EmployeeModel>> watchAll();
  Future<List<EmployeeModel>> getAll();
  Future<EmployeeModel?> getById(int id);
  Future<int> save(EmployeeModel employee);
  Future<void> delete(int id);
}

/// Isar implementasiýa
class IsarEmployeeRepository implements EmployeeRepository {
  Isar get _db => IsarService.isar;

  @override
  Stream<List<EmployeeModel>> watchAll() {
    return _db.employeeModels
        .where()
        .sortByName()
        .watch(fireImmediately: true);
  }

  @override
  Future<List<EmployeeModel>> getAll() =>
      _db.employeeModels.where().sortByName().findAll();

  @override
  Future<EmployeeModel?> getById(int id) => _db.employeeModels.get(id);

  @override
  Future<int> save(EmployeeModel employee) async {
    return await _db.writeTxn(() async {
      return await _db.employeeModels.put(employee);
    });
  }

  @override
  Future<void> delete(int id) async {
    await _db.writeTxn(() async {
      await _db.employeeModels.delete(id);
    });
  }
}
