import 'package:isar/isar.dart';

part 'table_model.g.dart';

/// Stolun ýagdaýy
enum TableStatus {
  /// Boş stol — müşderi ýok
  available,

  /// Aktiw stol — azyndan bir müşderi bar
  active,
}

/// Bilýard stoly
@collection
class TableModel {
  Id id = Isar.autoIncrement;

  /// Stolun ady: 'Stol 1', 'VIP', 'Championship' ş.m.
  @Index(unique: true, caseSensitive: false)
  late String name;

  /// Sagatlyk bahasy (TMT)
  late double pricePerHour;

  /// Maksimum oýunçy sany (niýetlenmedik bolsa null)
  int? maxUsers;

  /// Häzirki ýagdaýy
  @enumerated
  late TableStatus status;

  /// Döredilen wagty
  late DateTime createdAt;

  TableModel();

  factory TableModel.create({
    required String name,
    required double pricePerHour,
    int? maxUsers,
  }) =>
      TableModel()
        ..name = name.trim()
        ..pricePerHour = pricePerHour
        ..maxUsers = maxUsers
        ..status = TableStatus.available
        ..createdAt = DateTime.now();

  /// 1 minutlyk bahasy (TMT)
  double get pricePerMinute => pricePerHour / 60.0;

  bool get isAvailable => status == TableStatus.available;
  bool get isActive => status == TableStatus.active;

  @override
  String toString() => 'TableModel(id=$id, name=$name, status=$status)';
}