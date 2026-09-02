import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/reservation_notifications.dart';
import '../../../../data/models/reservation_model.dart';
import '../../../providers/providers.dart';
import '../../../providers/reservation_providers.dart';

/// Bron boýunça stoly başladýar.
///
/// [startTableFromReservation] bilen bir iş edýär, ýöne ekrany
/// ýapmaýar — işgäriň sanawy ýerinde galmaly.
Future<void> startTableFromBooking(
  WidgetRef ref,
  ReservationModel reservation,
) async {
  var discount = 0.0;
  final customerId = reservation.customerId;
  if (customerId != null) {
    final customer = await ref
        .read(customerRepositoryProvider)
        .getById(customerId);
    discount = customer?.discountPercentage ?? 0.0;
  }

  await ref
      .read(sessionNotifierProvider.notifier)
      .addPlayer(
        tableId: reservation.tableId,
        playerName: reservation.title,
        customerId: customerId,
        discountPercentage: discount,
      );

  await ref
      .read(reservationNotifierProvider.notifier)
      .markStarted(reservation.id);
  await ReservationNotifications.cancel(reservation.id);
}
