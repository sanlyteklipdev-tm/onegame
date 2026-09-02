import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/models/reservation_model.dart';

/// Bronyň ýagdaýyny görkezýän kiçi bellik
class WorkerStatusChip extends StatelessWidget {
  final ReservationStatus status;

  const WorkerStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    final (label, color) = switch (status) {
      ReservationStatus.pending => (s.statusPending, scheme.outline),
      ReservationStatus.started => (s.statusStarted, scheme.primary),
      ReservationStatus.done => (s.statusDone, scheme.tertiary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: color, fontSize: 10.5),
      ),
    );
  }
}
