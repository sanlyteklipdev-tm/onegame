import 'package:isar/isar.dart';

import '../local/isar_service.dart';
import '../models/table_model.dart';

/// Stol repository interfeýsi
abstract class TableRepository {
  Future<List<TableModel>> getAllTables();
  Future<TableModel?> getTableById(int id);
  Stream<List<TableModel>> watchAllTables();
  Future<TableModel> createTable(TableModel table);
  Future<void> updateTable(TableModel table);
  Future<void> deleteTable(int tableId);
  Future<void> updateTableStatus(int tableId, TableStatus status);
}

/// Isar-a esaslanýan implementasiýa
class IsarTableRepository implements TableRepository {
  Isar get _db => IsarService.isar;

  @override
  Future<List<TableModel>> getAllTables() async {
    return _db.tableModels.where().sortByName().findAll();
  }

  @override
  Future<TableModel?> getTableById(int id) async {
    return _db.tableModels.get(id);
  }

  @override
  Stream<List<TableModel>> watchAllTables() {
    return _db.tableModels.where().sortByName().watch(fireImmediately: true);
  }

  @override
  Future<TableModel> createTable(TableModel table) async {
    await _db.writeTxn(() async {
      table.id = await _db.tableModels.put(table);
    });
    return table;
  }

  @override
  Future<void> updateTable(TableModel table) async {
    await _db.writeTxn(() async {
      await _db.tableModels.put(table);
    });
  }

  @override
  Future<void> deleteTable(int tableId) async {
    await _db.writeTxn(() async {
      await _db.tableModels.delete(tableId);
    });
  }

  @override
  Future<void> updateTableStatus(int tableId, TableStatus status) async {
    await _db.writeTxn(() async {
      final table = await _db.tableModels.get(tableId);
      if (table != null) {
        table.status = status;
        await _db.tableModels.put(table);
      }
    });
  }
}
