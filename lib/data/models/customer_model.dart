import 'package:isar/isar.dart';

part 'customer_model.g.dart';

/// Müşderiniň kategoriýasy — häzirlikçe diňe bellik,
/// hiç zada täsir etmeýär.
enum CustomerCategory { a, b, c }

extension CustomerCategoryX on CustomerCategory {
  String get label => switch (this) {
    CustomerCategory.a => 'A',
    CustomerCategory.b => 'B',
    CustomerCategory.c => 'C',
  };

  static CustomerCategory fromDb(String value) => switch (value.trim()) {
    'B' => CustomerCategory.b,
    'C' => CustomerCategory.c,
    _ => CustomerCategory.a,
  };
}

@collection
class CustomerModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  late double discountPercentage;

  /// Habarlaşmak üçin telefon (hökman däl)
  String? phone;

  /// Kategoriýa (A/B/C) — bellik hökmünde
  @enumerated
  CustomerCategory category = CustomerCategory.a;

  @Index()
  late DateTime createdAt;

  /// Haýsy enjamdan goşuldy. Köne ýazgylarda boş.
  String? deviceName;

  CustomerModel();

  factory CustomerModel.create({
    required String name,
    required double discountPercentage,
    String? phone,
  }) {
    return CustomerModel()
      ..name = name
      ..discountPercentage = discountPercentage
      ..phone = phone
      ..createdAt = DateTime.now();
  }
}
