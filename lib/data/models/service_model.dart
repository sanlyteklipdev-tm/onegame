import 'package:isar/isar.dart';

part 'service_model.g.dart';

/// Hyzmat — bronda saýlanýan hyzmat (ady we bahasy)
@collection
class ServiceModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  late String name;

  /// Hyzmatyň bahasy (TMT)
  late double price;

  @Index()
  late DateTime createdAt;

  /// Haýsy enjamdan goşuldy. Köne ýazgylarda boş.
  String? deviceName;

  ServiceModel();

  factory ServiceModel.create({required String name, required double price}) =>
      ServiceModel()
        ..name = name.trim()
        ..price = price
        ..createdAt = DateTime.now();
}
