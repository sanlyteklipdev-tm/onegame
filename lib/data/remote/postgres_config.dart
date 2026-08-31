/// Настройки подключения к PostgreSQL.
///
/// Пока что — локальная база для тестирования. При переходе на сервер
/// меняется только это место — тот же подход, что и с [ApiConfig].
///
/// ВНИМАНИЕ: пароль хранится в коде. Это допустимо только для локального
/// тестирования. Перед распространением приложения между ним и базой
/// должен быть API-слой.
class PostgresConfig {
  PostgresConfig._();

  static const String host = '127.0.0.1';
  static const int port = 5432;
  static const String database = 'billiard';
  static const String username = 'billiard_app';

  /// Пароль не прописывается в коде — репозиторий открытый, история git
  /// сохраняется навсегда. Передаётся при сборке:
  ///   flutter run   -d windows --release --dart-define=PG_PASSWORD=...
  ///   flutter build apk        --release --dart-define=PG_PASSWORD=...
  static const String password = String.fromEnvironment(
    'PG_PASSWORD',
    defaultValue: 'change_me',
  );

  /// Локальный сетевой адрес компьютера для подключения с телефона.
  /// На телефоне 127.0.0.1 — это сам телефон, поэтому нужен этот адрес.
  static const String? lanHost = '192.168.0.110';

  /// Реально используемый хост
  static String get effectiveHost => lanHost ?? host;
}