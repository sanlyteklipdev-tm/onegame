import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/reservation_model.dart';
import '../../../providers/providers.dart';
import '../../../providers/reservation_providers.dart';
import 'reservation_block.dart';
import 'reservation_detail_actions.dart';
import 'reservation_form_sheet.dart';

class ReservationDetailSheet extends ConsumerWidget {
  final ReservationModel reservation;

  const ReservationDetailSheet({super.key, required this.reservation});

  void _openEdit(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ReservationFormSheet(existing: reservation),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final color = colorForTable(reservation.tableId);
    final tableName = ref.watch(tableNamesProvider)[reservation.tableId] ?? '';
    final employeeName = ref
        .watch(employeesStreamProvider)
        .maybeWhen(
          data: (list) => list
              .where((e) => e.id == reservation.employeeId)
              .map((e) => e.name)
              .firstOrNull,
          orElse: () => null,
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: color, radius: 6),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reservation.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                reservation.isStarted
                    ? s.reservationStartedLabel
                    : s.reservationPendingLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: reservation.isStarted ? Colors.green : scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$tableName · ${s.shortDateLabel(reservation.startTime)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '${AppFormatters.formatTime(reservation.startTime)} — '
            '${AppFormatters.formatTime(reservation.endTime)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (employeeName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  CupertinoIcons.briefcase,
                  size: 15,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  employeeName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          if (!reservation.isStarted)
            FilledButton.icon(
              onPressed: () => startTableFromReservation(
                context: context,
                ref: ref,
                reservation: reservation,
              ),
              icon: const Icon(CupertinoIcons.play_arrow_solid, size: 18),
              label: Text(s.startTableNow),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openEdit(context),
                  icon: const Icon(CupertinoIcons.pencil, size: 16),
                  label: Text(s.editReservation),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => deleteReservation(
                  context: context,
                  ref: ref,
                  reservation: reservation,
                ),
                icon: const Icon(CupertinoIcons.trash),
                color: scheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
