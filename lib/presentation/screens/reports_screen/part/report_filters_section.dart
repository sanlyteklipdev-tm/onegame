import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../providers/providers.dart';
import 'date_picker_card.dart';
import 'quick_filter_chip.dart';
import 'table_filter_row.dart';

class ReportFiltersSection extends ConsumerWidget {
  const ReportFiltersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(reportFilterProvider);
    final tablesAsync = ref.watch(tablesStreamProvider);
    final notifier = ref.read(reportFilterProvider.notifier);
    final s = S.of(context);

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              QuickFilterChip(label: s.today, onTap: notifier.setToday),
              const SizedBox(width: 8),
              QuickFilterChip(label: s.thisWeek, onTap: notifier.setThisWeek),
              const SizedBox(width: 8),
              QuickFilterChip(
                label: s.thisMonth,
                onTap: notifier.setThisMonth,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: DatePickerCard(
                  label: s.startDate,
                  date: filter.from,
                  onPick: notifier.setFrom,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DatePickerCard(
                  label: s.endDate,
                  date: filter.to,
                  onPick: notifier.setTo,
                ),
              ),
            ],
          ),
        ),
        tablesAsync.when(
          data: (tables) {
            if (tables.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: TableFilterRow(
                tables: tables,
                selectedId: filter.tableId,
                onSelect: notifier.setTable,
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (err, stack) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
