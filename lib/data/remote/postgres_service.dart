import 'dart:async';
import 'dart:developer' as dev;

import 'package:postgres/postgres.dart';

import 'postgres_config.dart';

/// PostgreSQL birikmesini dolandyrýan singleton.
///
/// Birikme ýitse, indiki sorag awtomatiki täzeden açýar.
class PostgresService {
  PostgresService._();

  static Connection? _connection;
  static Future<Connection>? _opening;

  /// Taýýar birikme. Gerek bolsa özi açýar.
  static Future<Connection> get connection async {
    final existing = _connection;
    if (existing != null && existing.isOpen) return existing;

    // Bir wagtda birnäçe sorag gelse, diňe bir birikme açylsyn
    return _opening ??= _open().whenComplete(() => _opening = null);
  }

  static Future<Connection> _open() async {
    final conn = await Connection.open(
      Endpoint(
        host: PostgresConfig.effectiveHost,
        port: PostgresConfig.port,
        database: PostgresConfig.database,
        username: PostgresConfig.username,
        password: PostgresConfig.password,
      ),
      settings: const ConnectionSettings(
        // Lokal bazada SSL sazlanmadyk
        sslMode: SslMode.disable,
        connectTimeout: Duration(seconds: 10),
      ),
    );
    _connection = conn;
    dev.log('PostgreSQL: connected to ${PostgresConfig.database}');
    return conn;
  }

  /// Birikmäniň barlagy — sazlamalar ekranynda ulanmak üçin amatly
  static Future<bool> ping() async {
    try {
      final conn = await connection;
      await conn.execute('SELECT 1');
      return true;
    } catch (e) {
      dev.log('PostgreSQL ping failed: $e');
      return false;
    }
  }

  /// Adly parametrler bilen sorag: `@id` görnüşinde
  static Future<Result> query(
    String sql, {
    Map<String, Object?> parameters = const {},
  }) async {
    final conn = await connection;
    if (parameters.isEmpty) return conn.execute(sql);
    return conn.execute(Sql.named(sql), parameters: parameters);
  }

  /// Birnäçe soragy bir tranzaksiýada ýerine ýetirýär
  static Future<T> transaction<T>(
    Future<T> Function(TxSession tx) action,
  ) async {
    final conn = await connection;
    return conn.runTx(action);
  }

  static Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
