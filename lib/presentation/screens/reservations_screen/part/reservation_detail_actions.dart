import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/reservation_notifications.dart';
import '../../../../data/models/reservation_model.dart';
import '../../../providers/providers.dart';
import '../../../providers/reservation_providers.dart';

/// Bron boýunça stoly başladýar: sessiýa döredýär we brony «başladyldy»
/// diýip belleýär. Awtomatiki başlamaýar — diňe elde basylanda.
Future<void> startTableFromReservation({
  required BuildContext context,
  required WidgetRef ref,
  required ReservationModel reservation,
}) async {
  final s = S.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

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

  navigator.pop();
  messenger.showSnackBar(
    SnackBar(
      content: Text(s.reservationTableStarted),
      backgroundColor: Colors.green,
    ),
  );
}

/// Tassyklama soraýar we brony pozýar (duýduryşlary hem ýatyrýar)
Future<void> deleteReservation({
  required BuildContext context,
  required WidgetRef ref,
  required ReservationModel reservation,
}) async {
  final s = S.of(context);
  final navigator = Navigator.of(context);
  final errorColor = Theme.of(context).colorScheme.error;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(s.deleteReservation),
      content: Text(s.reservationDeleteConfirm(reservation.title)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(s.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: errorColor,
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(s.delete),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  await ref.read(reservationNotifierProvider.notifier).delete(reservation.id);
  await ReservationNotifications.cancel(reservation.id);
  navigator.pop();
}
