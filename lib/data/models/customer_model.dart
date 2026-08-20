import 'package:isar/isar.dart';

part 'customer_model.g.dart';

@collection
class CustomerModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String name;

  late double discountPercentage;

  @Index()
  late DateTime createdAt;

  CustomerModel();

  factory CustomerModel.create({
    required String name,
    required double discountPercentage,
  }) {
    return CustomerModel()
      ..name = name
      ..discountPercentage = discountPercentage
      ..createdAt = DateTime.now();
  }
}
