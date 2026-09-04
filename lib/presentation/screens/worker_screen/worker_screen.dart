import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/booking_watch_service.dart';
import '../../../core/services/worker_notification_sync.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/reservation_model.dart';
import '../../providers/auth_providers.dart';
import '../../providers/reservation_providers.dart';
import '../../widgets/entity_grid.dart';
import '../../widgets/sign_out_action.dart';
import 'part/worker_booking_actions.dart';
import 'part/worker_booking_card.dart';
import 'part/worker_empty_state.dart';

/// Işgäriň ekrany — diňe öz bronlary.
/// Menýu ýok: beýleki bölümler bu rola elýeterli däl.
class WorkerScreen extends ConsumerStatefulWidget {
  const WorkerScreen({super.key});

  @override
  ConsumerState<WorkerScreen> createState() => _WorkerScreenState();
}

class _WorkerScreenState extends ConsumerState<WorkerScreen> {
  int? _busyId;

  @override
  void initState() {
    super.initState();
    // Duýduryş we batareýa rugsatlary. Ulgamyň sazlama sahypasyny
    // açyp bilýär — şonuň üçin ekran gurlandan soň soralýar.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => BookingWatchService.requestPermissions(),
    );
  }

  Future<void> _run(int id, Future<void> Function() action) async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _busyId = id);
    try {
      await action();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('${s.errorPrefix}: $e')));
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  /// Bron sanawy üýtgände duýduryşlary sazlaýar
  void _syncNotifications(List<ReservationModel> bookings) {
    final s = S.of(context);
    final tableNames = ref.read(tableNamesProvider);

    String where(ReservationModel r) => tableNames[r.tableId] ?? '';
    String when(ReservationModel r) => AppFormatters.formatTime(r.startTime);

    WorkerNotificationSync.sync(
      bookings: bookings,
      newTitle: (_) => s.newBookingTitle,
      newBody: (r) => s.newBookingBody(r.title, where(r), when(r)),
      soonTitle: (_) => s.bookingSoonTitle,
      soonBody: (r) => s.newBookingBody(r.title, where(r), when(r)),
      startTitle: (_) => s.bookingNowTitle,
      startBody: (r) => s.newBookingBody(r.title, where(r), when(r)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final user = ref.watch(authProvider);
    final bookings = ref.watch(myReservationsProvider);
    final tableNames = ref.watch(tableNamesProvider);
    final serviceNames = ref.watch(serviceNamesProvider);

    // Sanaw täzelenende duýduryşlar hem täzelenýär
    ref.listen(myReservationsProvider, (_, next) {
      next.whenData(_syncNotifications);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(s.myBookings),
        centerTitle: false,
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          IconButton(
            tooltip: s.signOut,
            icon: const Icon(CupertinoIcons.square_arrow_right),
            onPressed: () => confirmSignOut(context, ref),
          ),
        ],
      ),
      body: user?.employeeId == null
          ? WorkerEmptyState(
              icon: CupertinoIcons.person_crop_circle_badge_exclam,
              title: s.notLinkedToEmployee,
            )
          : bookings.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${s.errorPrefix}: $e')),
              data: (list) {
                if (list.isEmpty) {
                  return WorkerEmptyState(
                    icon: CupertinoIcons.calendar,
                    title: s.noMyBookings,
                    subtitle: s.noMyBookingsHint,
                  );
                }

                // Stollar ekranyndaky ýaly gönüburçluk gözenek.
                // Kartda düwmeler bar — şonuň üçin beýiklik köpräk
                // we sütünler 4-den geçenok, ýogsam düwmeler gysylýar.
                final columns = EntityGrid.crossAxisCount(
                  MediaQuery.sizeOf(context).width,
                  max: 4,
                );

                return EntityGrid(
                  maxCrossAxisCount: 4,
                  childAspectRatio: columns >= 3 ? 1.15 : 0.92,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final r = list[i];
                    return WorkerBookingCard(
                      reservation: r,
                      tableName: tableNames[r.tableId] ?? '',
                      serviceName: serviceNames[r.serviceId],
                      isBusy: _busyId == r.id,
                      onStart: () => _run(
                        r.id,
                        () => startTableFromBooking(ref, r),
                      ),
                      onDone: () => _run(
                        r.id,
                        () => ref
                            .read(reservationNotifierProvider.notifier)
                            .markDone(r.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
