/// Maglumatlaryň nireden alynýandygy.
///
/// Isar — lokal baza, internetsiz hem işleýär (häzirki esasy ýol).
/// Postgres — synag üçin goşulan daşarky baza.
///
/// Çalyşmak üçin diňe [current] üýtgedilýär, ekranlar we providerler
/// üýtgemeýär — ikisi hem birmeňzeş repository interfeýslerini ulanýar.
enum DataSource { isar, postgres }

class DataSourceConfig {
  DataSourceConfig._();

  /// Häzirki çeşme. Postgres synagy üçin `DataSource.postgres` ediň.
  static const DataSource current = DataSource.isar;

  static bool get usePostgres => current == DataSource.postgres;
}
