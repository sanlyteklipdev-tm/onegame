import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/providers.dart';
import 'revenue_summary_card.dart';

class ReportRevenueCard extends ConsumerWidget {
  const ReportRevenueCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(reportFilterProvider);
    final revenueAsync = ref.watch(filteredRevenueProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: revenueAsync.when(
        loading: () => const RevenueSkeleton(),
        error: (e, stack) => Text('$e'),
        data: (revenue) => RevenueSummaryCard(
          revenue: revenue,
          from: filter.from,
          to: filter.to,
        ),
      ),
    );
  }
}
