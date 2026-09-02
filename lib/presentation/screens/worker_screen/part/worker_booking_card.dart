import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/reservation_model.dart';
import '../../../widgets/device_chip.dart';
import 'worker_status_chip.dart';

/// Işgäriň bir brony — stollar ekranyndaky ýaly gönüburçluk kart.
class WorkerBookingCard extends StatelessWidget {
  final ReservationModel reservation;
  final String tableName;
  final String? serviceName;
  final bool isBusy;
  final VoidCallback onStart;
  final VoidCallback onDone;

  const WorkerBookingCard({
    super.key,
    required this.reservation,
    required this.tableName,
    required this.serviceName,
    required this.isBusy,
    required this.onStart,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final r = reservation;

    final time =
        '${AppFormatters.formatTime(r.startTime)} — '
        '${AppFormatters.formatTime(r.endTime)}';

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: 6),
                WorkerStatusChip(status: r.status),
              ],
            ),

            const SizedBox(height: 8),

            _Line(icon: CupertinoIcons.clock, text: time),
            _Line(icon: CupertinoIcons.table, text: tableName),
            if (serviceName != null)
              _Line(icon: CupertinoIcons.sparkles, text: serviceName!),

            const Spacer(),

            DeviceChip(deviceName: r.deviceName, dense: true),

            // Ýerine ýetirilen bronda düwme gerek däl
            if (!r.isDone) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (!r.isStarted) ...[
                    Expanded(
                      child: _CompactButton(
                        filled: false,
                        icon: CupertinoIcons.play_arrow,
                        label: s.startTableNow,
                        onPressed: isBusy ? null : onStart,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: _CompactButton(
                      filled: true,
                      icon: CupertinoIcons.check_mark,
                      label: s.markDone,
                      onPressed: isBusy ? null : onDone,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Kartda ýer az — şonuň üçin pes we gysby düwme
class _CompactButton extends StatelessWidget {
  final bool filled;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _CompactButton({
    required this.filled,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final child = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );

    final style = ButtonStyle(
      minimumSize: WidgetStateProperty.all(const Size.fromHeight(36)),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 8),
      ),
      textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 12.5)),
    );

    return filled
        ? FilledButton(onPressed: onPressed, style: style, child: child)
        : OutlinedButton(onPressed: onPressed, style: style, child: child);
  }
}

class _Line extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Line({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
