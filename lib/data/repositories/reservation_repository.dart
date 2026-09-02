import 'package:isar/isar.dart';

import '../local/isar_service.dart';
import '../models/reservation_model.dart';

/// Bron repository interfeýsi
abstract class ReservationRepository {
  /// Bellenilen günüň bronlary (başlangyç wagty boýunça tertipde)
  Stream<List<ReservationModel>> watchByDay(DateTime day);

  Future<ReservationModel?> getById(int id);

  /// Şol stolda, şol wagt aralygynda gabat gelýän bron (bar bolsa).
  /// [excludeId] — redaktirlenýän bronyň özüni hasaba almazlyk üçin.
  Future<ReservationModel?> findOverlapping({
    required int tableId,
    required DateTime start,
    required DateTime end,
    int? excludeId,
  });

  Future<int> save(ReservationModel reservation);
  Future<void> markStarted(int id);

  /// Işgär brony ýerine ýetirdi diýip belleýär
  Future<void> markDone(int id);

  /// Bir işgäriň bronlary — [from] pursadyndan soň başlaýanlar.
  /// Işgäriň ekrany diňe şulary görkezýär.
  Stream<List<ReservationModel>> watchForEmployee(
    int employeeId, {
    required DateTime from,
  });

  Future<void> delete(int id);
}

/// Isar implementasiýa
class IsarReservationRepository implements ReservationRepository {
  Isar get _db => IsarService.isar;

  @override
  Stream<List<ReservationModel>> watchByDay(DateTime day) {
    final from = DateTime(day.year, day.month, day.day);
    final to = from.add(const Duration(days: 1));

    return _db.reservationModels
        .filter()
        .startTimeGreaterThan(from, include: true)
        .startTimeLessThan(to)
        .sortByStartTime()
        .watch(fireImmediately: true);
  }

  @override
  Future<ReservationModel?> getById(int id) => _db.reservationModels.get(id);

  @override
  Future<ReservationModel?> findOverlapping({
    required int tableId,
    required DateTime start,
    required DateTime end,
    int? excludeId,
  }) async {
    // Gabat gelmek şerti: bar bolan.start < täze.end && bar bolan.end > täze.start
    final candidates = await _db.reservationModels
        .filter()
        .tableIdEqualTo(tableId)
        .startTimeLessThan(end)
        .findAll();

    for (final r in candidates) {
      if (r.id == excludeId) continue;
      if (r.endTime.isAfter(start)) return r;
    }
    return null;
  }

  @override
  Future<int> save(ReservationModel reservation) async {
    return await _db.writeTxn(() async {
      return await _db.reservationModels.put(reservation);
    });
  }

  @override
  Future<void> markStarted(int id) async {
    await _db.writeTxn(() async {
      final r = await _db.reservationModels.get(id);
      if (r == null) return;
      r.status = ReservationStatus.started;
      await _db.reservationModels.put(r);
    });
  }

  @override
  Future<void> markDone(int id) async {
    await _db.writeTxn(() async {
      final r = await _db.reservationModels.get(id);
      if (r == null) return;
      r.status = ReservationStatus.done;
      await _db.reservationModels.put(r);
    });
  }

  @override
  Stream<List<ReservationModel>> watchForEmployee(
    int employeeId, {
    required DateTime from,
  }) {
    return _db.reservationModels
        .filter()
        .employeeIdEqualTo(employeeId)
        .endTimeGreaterThan(from)
        .sortByStartTime()
        .watch(fireImmediately: true);
  }

  @override
  Future<void> delete(int id) async {
    await _db.writeTxn(() async {
      await _db.reservationModels.delete(id);
    });
  }
}
