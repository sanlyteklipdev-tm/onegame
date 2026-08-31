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

  /// Häzirki çeşme. Isar-a dolanmak üçin `DataSource.isar` ediň.
  static const DataSource current = DataSource.postgres;

  static bool get usePostgres => current == DataSource.postgres;
}
