import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';

class RevenueSummaryCard extends StatelessWidget {
  final double revenue;
  final DateTime from;
  final DateTime to;

  const RevenueSummaryCard({
    super.key,
    required this.revenue,
    required this.from,
    required this.to,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    final sameDay =
        from.day == to.day && from.month == to.month && from.year == to.year;

    final label = sameDay
        ? AppFormatters.smartDateLabel(from)
        : '${AppFormatters.formatDate(from)} — ${AppFormatters.formatDate(to)}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            Color.from(
              alpha: scheme.primary.a,
              red: scheme.primary.r,
              green: (scheme.primary.g + (30 / 255)).clamp(0, 1),
              blue: scheme.primary.b,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: scheme.onPrimary.withAlpha(204),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${AppFormatters.formatPriceRaw(revenue)} ${s.tmt}',
            style: TextStyle(
              color: scheme.onPrimary,
              fontSize: 40,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            s.totalRevenue,
            style: TextStyle(color: scheme.onPrimary.withAlpha(179), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class RevenueSkeleton extends StatelessWidget {
  const RevenueSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
