import 'package:isar/isar.dart';

import '../local/isar_service.dart';
import '../models/service_model.dart';

/// Hyzmat repository interfeýsi
abstract class ServiceRepository {
  Stream<List<ServiceModel>> watchAll();
  Future<List<ServiceModel>> getAll();
  Future<ServiceModel?> getById(int id);
  Future<int> save(ServiceModel service);
  Future<void> delete(int id);
}

/// Isar implementasiýa
class IsarServiceRepository implements ServiceRepository {
  Isar get _db => IsarService.isar;

  @override
  Stream<List<ServiceModel>> watchAll() =>
      _db.serviceModels.where().sortByName().watch(fireImmediately: true);

  @override
  Future<List<ServiceModel>> getAll() =>
      _db.serviceModels.where().sortByName().findAll();

  @override
  Future<ServiceModel?> getById(int id) => _db.serviceModels.get(id);

  @override
  Future<int> save(ServiceModel service) async {
    return await _db.writeTxn(() async {
      return await _db.serviceModels.put(service);
    });
  }

  @override
  Future<void> delete(int id) async {
    await _db.writeTxn(() async {
      await _db.serviceModels.delete(id);
    });
  }
}
