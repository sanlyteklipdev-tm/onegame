import 'package:isar/isar.dart';

part 'reservation_model.g.dart';

/// Bronyň ýagdaýy
enum ReservationStatus {
  /// Wagtyna garaşylýar, stol heniz başladylmady
  pending,

  /// Bron boýunça stol başladyldy
  started,

  /// Işgär brony ýerine ýetirdi diýip belledi
  done,
}

/// Stol brony — geljekki wagt üçin ýazgy.
/// Sessiýadan tapawutlylykda özi awtomatiki başlamaýar.
@collection
class ReservationModel {
  Id id = Isar.autoIncrement;

  /// Haýsy stol bronlanan
  @Index()
  late int tableId;

  /// Bronyň ady (müşderiniň ady ýa-da erkin tekst)
  late String title;

  /// Baglanyşykly müşderi (CustomerModel). Saýlanmadyk bolsa null.
  int? customerId;

  /// Jogapkär işgär (EmployeeModel). Saýlanmadyk bolsa null.
  int? employeeId;

  /// Saýlanan hyzmat (ServiceModel). Täze bronlarda hökman,
  /// köne ýazgylarda boş bolup biler.
  int? serviceId;

  /// Bron başlaýan wagt
  @Index()
  late DateTime startTime;

  /// Bron tamamlanýan wagt
  late DateTime endTime;

  @enumerated
  late ReservationStatus status;

  late DateTime createdAt;

  /// Haýsy enjamdan goşuldy. Köne ýazgylarda boş.
  String? deviceName;

  ReservationModel();

  factory ReservationModel.create({
    required int tableId,
    required String title,
    required DateTime startTime,
    required DateTime endTime,
    int? customerId,
    int? employeeId,
    int? serviceId,
  }) =>
      ReservationModel()
        ..tableId = tableId
        ..title = title.trim()
        ..customerId = customerId
        ..employeeId = employeeId
        ..serviceId = serviceId
        ..startTime = startTime
        ..endTime = endTime
        ..status = ReservationStatus.pending
        ..createdAt = DateTime.now();

  bool get isPending => status == ReservationStatus.pending;
  bool get isStarted => status == ReservationStatus.started;
  bool get isDone => status == ReservationStatus.done;

  @ignore
  Duration get duration => endTime.difference(startTime);

  @override
  String toString() =>
      'Reservation(id=$id, table=$tableId, title=$title, status=$status)';
}
