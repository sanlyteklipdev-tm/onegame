import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../../data/models/player_session_model.dart';
import '../../../providers/providers.dart';

class TotalCostCard extends ConsumerWidget {
  final List<PlayerSessionModel> sessions;
  final double pricePerHour;
  final VoidCallback onCloseTable;

  const TotalCostCard({
    super.key,
    required this.sessions,
    required this.pricePerHour,
    required this.onCloseTable,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(timerProvider);
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    double totalCost = 0;
    Duration longestDuration = Duration.zero;

    for (final st in sessions) {
      final cost = PriceCalculator.currentSessionCost(
        accumulatedCost: st.accumulatedCost,
        lastCheckpointTime: st.lastCheckpointTime,
        pricePerHour: pricePerHour,
        currentActiveCount: sessions.length,
      );
      totalCost += cost;
      final dur = DateTime.now().difference(st.startTime);
      if (dur > longestDuration) longestDuration = dur;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.tableTotalBill,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer.withAlpha(179),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppFormatters.formatPriceRaw(totalCost)} ${s.tmt}',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(
                          color: scheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    s.time,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: scheme.onPrimaryContainer.withAlpha(179),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.formatDuration(longestDuration),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onCloseTable,
              icon: const Icon(
                CupertinoIcons.rectangle_stack_person_crop_fill,
                size: 18,
              ),
              label: Text(s.closeTotalTable),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
