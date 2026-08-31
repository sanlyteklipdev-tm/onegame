import 'package:isar/isar.dart';

part 'employee_model.g.dart';

/// Işgäriň wezipesi. Ady ekranda dile görä görkezilýär —
/// [S.positionLabel] serediň.
enum EmployeePosition { manager, cashier, operator, director }

extension EmployeePositionX on EmployeePosition {
  /// Bazada saklanýan gymmatlyk
  String get dbValue => switch (this) {
    EmployeePosition.manager => 'manager',
    EmployeePosition.cashier => 'cashier',
    EmployeePosition.operator => 'operator',
    EmployeePosition.director => 'director',
  };

  static EmployeePosition fromDb(String value) => switch (value.trim()) {
    'cashier' => EmployeePosition.cashier,
    'operator' => EmployeePosition.operator,
    'director' => EmployeePosition.director,
    _ => EmployeePosition.manager,
  };
}

/// Işgäriň görnüşi. Bronda diňe [EmployeeType.type2] saýlanyp bilinýär.
enum EmployeeType { type1, type2 }

extension EmployeeTypeX on EmployeeType {
  /// Bazada saklanýan gymmatlyk
  String get dbValue => switch (this) {
    EmployeeType.type1 => 'type1',
    EmployeeType.type2 => 'type2',
  };

  static EmployeeType fromDb(String value) =>
      value.trim() == 'type2' ? EmployeeType.type2 : EmployeeType.type1;
}

/// Işgär — brona jogapkär bellenip bilinýän işgär
@collection
class EmployeeModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  /// Habarlaşmak üçin telefon (hökman däl)
  String? phone;

  /// Wezipe — hökman saýlanmaly, boş bolup bilmeýär
  @enumerated
  EmployeePosition position = EmployeePosition.manager;

  /// Görnüş — hökman saýlanmaly. Bronda diňe 2-nji görnüş görkezilýär.
  @enumerated
  EmployeeType type = EmployeeType.type1;

  @Index()
  late DateTime createdAt;

  /// Haýsy enjamdan goşuldy. Köne ýazgylarda boş.
  String? deviceName;

  EmployeeModel();

  factory EmployeeModel.create({
    required String name,
    String? phone,
    EmployeePosition position = EmployeePosition.manager,
    EmployeeType type = EmployeeType.type1,
  }) =>
      EmployeeModel()
        ..name = name.trim()
        ..phone = phone
        ..position = position
        ..type = type
        ..createdAt = DateTime.now();
}
