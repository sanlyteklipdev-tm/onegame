import 'dart:async';
import 'dart:developer' as dev;

import 'package:postgres/postgres.dart';

import 'postgres_config.dart';

/// PostgreSQL birikmesini dolandyrýan singleton.
///
/// Ulanyjynyň ady we paroly girişde berilýär — programmanyň içinde
/// saklanmaýar. Şonuň üçin hukuklary bazanyň özi barlaýar:
/// işgäriň programmasy hasabatlary okap bilmeýär, sebäbi baza
/// rugsat bermeýär, programma "gizleýändigi" üçin däl.
class PostgresService {
  PostgresService._();

  static Connection? _connection;
  static Future<Connection>? _opening;

  static String? _username;
  static String? _password;

  /// Häzir kim girdi. Girilmedik bolsa `null`.
  static String? get currentUser => _username;

  static bool get isSignedIn => _username != null && _password != null;

  /// Taýýar birikme. Birikme ýitse özi täzeden açýar.
  static Future<Connection> get connection async {
    final existing = _connection;
    if (existing != null && existing.isOpen) return existing;

    final user = _username;
    final pass = _password;
    if (user == null || pass == null) {
      throw StateError('PostgreSQL: girilmedik — öňürti signIn çagyrylmaly');
    }

    // Bir wagtda birnäçe sorag gelse, diňe bir birikme açylsyn
    return _opening ??= _open(user, pass).whenComplete(() => _opening = null);
  }

  static Future<Connection> _open(String username, String password) async {
    final conn = await Connection.open(
      Endpoint(
        host: PostgresConfig.effectiveHost,
        port: PostgresConfig.port,
        database: PostgresConfig.database,
        username: username,
        password: password,
      ),
      settings: const ConnectionSettings(
        // Lokal bazada SSL sazlanmadyk
        sslMode: SslMode.disable,
        connectTimeout: Duration(seconds: 10),
      ),
    );
    _connection = conn;
    dev.log('PostgreSQL: $username connected to ${PostgresConfig.database}');
    return conn;
  }

  /// Girişi barlaýar. Şowsuz bolsa ýalňyşlyk zyňýar we
  /// öňki ýagdaý üýtgemän galýar.
  static Future<void> signIn({
    required String username,
    required String password,
  }) async {
    await close();
    // Ýalňyş parol bolsa şu ýerde ýalňyşlyk zyňylýar
    await _open(username, password);
    _username = username;
    _password = password;
  }

  static Future<void> signOut() async {
    await close();
    _username = null;
    _password = null;
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
