import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/formatters.dart';
import '../../../providers/providers.dart';
import 'reservation_layout.dart';

/// Häzirki wagty görkezýän gyzyl çyzyk
class CurrentTimeIndicator extends ConsumerWidget {
  const CurrentTimeIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Her sekuntda täzelenýär — diňe şu widget gaýtadan gurulýar
    ref.watch(timerProvider);

    const color = Color(0xFFE53935);
    final now = DateTime.now();

    return Positioned(
      top: offsetForTime(now) - 5,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: kTimeGutter - 6,
            alignment: Alignment.centerRight,
            // Ýanaşyk sagat sanyny ýapmak üçin dury däl fon
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            child: Text(
              AppFormatters.formatTime(now),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 2),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const Expanded(child: Divider(color: color, thickness: 1, height: 1)),
        ],
      ),
    );
  }
}
