import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/table_model.dart';
import '../models/player_session_model.dart';
import '../models/history_log_model.dart';
import '../models/app_settings_model.dart';
import '../models/customer_model.dart';

/// Isar database singleton servisi
class IsarService {
  IsarService._();

  static Isar? _isar;

  static Isar get isar {
    assert(_isar != null, 'IsarService.initialize() çagyryň!');
    return _isar!;
  }

  static Future<void> initialize() async {
    if (_isar != null) return;

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [TableModelSchema, PlayerSessionModelSchema, HistoryLogModelSchema, AppSettingsModelSchema, CustomerModelSchema],
      directory: dir.path,
      name: 'billiard_db',
      inspector: false, // Production-da false
    );
  }

  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  /// Ähli maglumatlary poz (reset)
  static Future<void> clearAll() async {
    await _isar?.writeTxn(() async {
      await _isar?.clear();
    });
  }
}
