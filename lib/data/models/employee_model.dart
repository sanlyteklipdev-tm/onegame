import 'package:isar/isar.dart';

part 'employee_model.g.dart';

/// Işgäriň derejesi
enum EmployeeCategory { a, b, c }

extension EmployeeCategoryX on EmployeeCategory {
  String get label => switch (this) {
    EmployeeCategory.a => 'A',
    EmployeeCategory.b => 'B',
    EmployeeCategory.c => 'C',
  };
}

/// Işgär — brona jogapkär bellenip bilinýän işgär
@collection
class EmployeeModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  /// Habarlaşmak üçin telefon (hökman däl)
  String? phone;

  /// Dereje. Öň ýazylan işgärlerde awtomatiki `A` bolýar.
  @enumerated
  EmployeeCategory category = EmployeeCategory.a;

  @Index()
  late DateTime createdAt;

  EmployeeModel();

  factory EmployeeModel.create({
    required String name,
    String? phone,
    EmployeeCategory category = EmployeeCategory.a,
  }) =>
      EmployeeModel()
        ..name = name.trim()
        ..phone = phone
        ..category = category
        ..createdAt = DateTime.now();
}
