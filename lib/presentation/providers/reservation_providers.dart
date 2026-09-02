import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../data/models/reservation_model.dart';
import '../../data/models/service_model.dart';
import '../../data/models/table_model.dart';
import '../../data/data_source.dart';
import 'auth_providers.dart';
import 'providers.dart';
import '../../data/repositories/pg/pg_reservation_repository.dart';
import '../../data/repositories/reservation_repository.dart';

/// Şol stol şol wagt aralygynda eýýäm bronlanan
class ReservationOverlapException implements Exception {
  final String tableName;
  ReservationOverlapException(this.tableName);
}

/// Tamamlanýan wagt başlangyçdan öň ýa-da deň
class InvalidReservationRangeException implements Exception {}

final reservationRepositoryProvider = Provider<ReservationRepository>(
  (ref) => DataSourceConfig.usePostgres
      ? PgReservationRepository()
      : IsarReservationRepository(),
);

// ── Saýlanan gün ────────────────────────────────────────────

class SelectedReservationDate extends Notifier<DateTime> {
  @override
  DateTime build() => AppFormatters.startOfDay(DateTime.now());

  void setDate(DateTime date) => state = AppFormatters.startOfDay(date);
  void nextDay() => state = state.add(const Duration(days: 1));
  void previousDay() => state = state.subtract(const Duration(days: 1));
  void goToToday() => state = AppFormatters.startOfDay(DateTime.now());
}

final selectedReservationDateProvider =
    NotifierProvider<SelectedReservationDate, DateTime>(
      SelectedReservationDate.new,
    );

// ── Stol süzgüji (null = ähli stollar) ──────────────────────

class ReservationTableFilter extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? tableId) => state = tableId;
}

final reservationTableFilterProvider =
    NotifierProvider<ReservationTableFilter, int?>(ReservationTableFilter.new);

// ── Saýlanan günüň bronlary ─────────────────────────────────

final dayReservationsProvider = StreamProvider<List<ReservationModel>>((ref) {
  final date = ref.watch(selectedReservationDateProvider);
  final repo = ref.watch(reservationRepositoryProvider);
  return repo.watchByDay(date);
});

/// Süzgüç ulanylan bronlar
final visibleReservationsProvider =
    Provider<AsyncValue<List<ReservationModel>>>((ref) {
      final filter = ref.watch(reservationTableFilterProvider);
      return ref.watch(dayReservationsProvider).whenData((list) {
        if (filter == null) return list;
        return list.where((r) => r.tableId == filter).toList();
      });
    });

// ── Bron işlemleri ──────────────────────────────────────────

class ReservationNotifier extends AsyncNotifier<void> {
  ReservationRepository get _repo => ref.read(reservationRepositoryProvider);

  @override
  Future<void> build() async {}

  /// Brony ýazdyrýar. Gabat gelme ýa-da nädogry aralyk bolsa exception atýar.
  /// Netijede ýazylan bronyň id-sini gaýtarýar.
  Future<int> save(ReservationModel reservation) async {
    if (!reservation.endTime.isAfter(reservation.startTime)) {
      throw InvalidReservationRangeException();
    }

    final clash = await _repo.findOverlapping(
      tableId: reservation.tableId,
      start: reservation.startTime,
      end: reservation.endTime,
      excludeId: reservation.id,
    );

    if (clash != null) {
      final table = await ref
          .read(tableRepositoryProvider)
          .getTableById(clash.tableId);
      throw ReservationOverlapException(table?.name ?? '');
    }

    return _repo.save(reservation);
  }

  Future<void> markStarted(int id) => _repo.markStarted(id);

  Future<void> markDone(int id) => _repo.markDone(id);

  Future<void> delete(int id) => _repo.delete(id);
}

final reservationNotifierProvider =
    AsyncNotifierProvider<ReservationNotifier, void>(ReservationNotifier.new);

/// Bronda görkezmek üçin hyzmat atlary: {serviceId: at}
final serviceNamesProvider = Provider<Map<int, String>>((ref) {
  final services = ref
      .watch(servicesStreamProvider)
      .maybeWhen(data: (x) => x, orElse: () => <ServiceModel>[]);
  return {for (final x in services) x.id: x.name};
});

/// Bronda görkezmek üçin stol atlary: {tableId: at}
/// Stollar repository arkaly alynýar — çeşme Isar ýa-da Postgres bolup biler.
final tableNamesProvider = Provider<Map<int, String>>((ref) {
  final tables = ref
      .watch(tablesStreamProvider)
      .maybeWhen(data: (t) => t, orElse: () => <TableModel>[]);
  return {for (final t in tables) t.id: t.name};
});

// ── Işgäriň öz bronlary ─────────────────────────────────────

/// Giren işgäriň gutarmadyk bronlary — wagt boýunça tertipde.
/// Hasaba işgär baglanmadyk bolsa boş sanaw gaýtarýar.
final myReservationsProvider = StreamProvider<List<ReservationModel>>((ref) {
  final employeeId = ref.watch(currentEmployeeIdProvider);
  if (employeeId == null) return Stream.value(const []);

  final repo = ref.watch(reservationRepositoryProvider);
  // Gündüziň başyndan — şu gün eýýäm geçen bronlar hem görünsin
  return repo.watchForEmployee(
    employeeId,
    from: AppFormatters.startOfDay(DateTime.now()),
  );
});
