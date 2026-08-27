/// PostgreSQL birikme sazlamalary.
///
/// Häzirlikçe synag üçin lokal baza. Serwere geçilende diňe şu ýer
/// üýtgeýär — [ApiConfig] bilen deň ýörelge.
///
/// ÜNS: parol kodda saklanýar. Bu diňe lokal synag üçin kabul ederlik.
/// Programma paýlanmazdan öň arasynda API gatlagy bolmaly.
class PostgresConfig {
  PostgresConfig._();

  static const String host = '127.0.0.1';
  static const int port = 5432;
  static const String database = 'billiard';
  static const String username = 'billiard_app';
  static const String password = 'Bil_7kQm2xTvZ9';

  /// Telefondan birikmek üçin kompýuteriň ýerli tor salgysy gerek
  /// (127.0.0.1 telefonda öz özüne salgylanýar).
  /// Meselem: '192.168.1.50'
  static const String? lanHost = null;

  /// Hakyky ulanylýan host
  static String get effectiveHost => lanHost ?? host;
}
