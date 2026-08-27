import 'package:isar/isar.dart';

part 'customer_model.g.dart';

@collection
class CustomerModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  late double discountPercentage;

  /// Habarlaşmak üçin telefon (hökman däl)
  String? phone;

  @Index()
  late DateTime createdAt;

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
