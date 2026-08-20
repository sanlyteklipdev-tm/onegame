import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/history_log_model.dart';
import '../../data/models/table_model.dart';
import '../providers/providers.dart';
import '../widgets/receipt_dialog.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(reportFilterProvider);
    final revenueAsync = ref.watch(filteredRevenueProvider);
    final historyAsync = ref.watch(filteredHistoryProvider);
    final tablesAsync = ref.watch(tablesStreamProvider);
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Başlyk ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text(
                  s.reports,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // ── Çalt filtrler ─────────────────────────────────
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    _QuickFilterChip(
                      label: s.today,
                      onTap: () => ref.read(reportFilterProvider.notifier).setToday(),
                    ),
                    const SizedBox(width: 8),
                    _QuickFilterChip(
                      label: s.thisWeek,
                      onTap: () => ref.read(reportFilterProvider.notifier).setThisWeek(),
                    ),
                    const SizedBox(width: 8),
                    _QuickFilterChip(
                      label: s.thisMonth,
                      onTap: () => ref.read(reportFilterProvider.notifier).setThisMonth(),
                    ),
                  ],
                ),
              ),
            ),

            // ── Aralyk saýlaýjy ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _DatePickerCard(
                        label: s.startDate,
                        date: filter.from,
                        onPick: (dt) => ref.read(reportFilterProvider.notifier).setFrom(dt),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DatePickerCard(
                        label: s.endDate,
                        date: filter.to,
                        onPick: (dt) => ref.read(reportFilterProvider.notifier).setTo(dt),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Stol filtri ────────────────────────────────────
            SliverToBoxAdapter(
              child: tablesAsync.when(
                data: (tables) {
                  if (tables.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: _TableFilterRow(
                      tables: tables,
                      selectedId: filter.tableId,
                      onSelect: (id) => ref.read(reportFilterProvider.notifier).setTable(id),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
              ),
            ),

            // ── Jemi girdeji kartasy ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: revenueAsync.when(
                  loading: () => const _RevenueSkeleton(),
                  error: (e, stack) => Text('$e'),
                  data: (revenue) => _RevenueSummaryCard(
                    revenue: revenue,
                    from: filter.from,
                    to: filter.to,
                  ),
                ),
              ),
            ),

            // ── Taryh sanawy ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  s.history,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            historyAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, stack) => SliverToBoxAdapter(child: Text('$e')),
              data: (logs) {
                if (logs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              CupertinoIcons.doc_text,
                              size: 48,
                              color: scheme.onSurfaceVariant.withAlpha(77), // 0.3 * 255
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.noHistory,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList.builder(
                  itemCount: logs.length,
                  itemBuilder: (ctx, i) => GestureDetector(
                    onTap: () => ReceiptDialog.show(context, logs[i]),
                    child: _ReportLogTile(log: logs[i]),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ─── Çalt filtr çipi ────────────────────────────────────────
class _QuickFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickFilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline.withAlpha(77), // 0.3 * 255
      ),
    );
  }
}

// ─── Sene saýlaýjy ──────────────────────────────────────────
class _DatePickerCard extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  const _DatePickerCard({required this.label, required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 1)),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest.withAlpha(128), // 0.5 * 255
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant.withAlpha(102)), // 0.4 * 255
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.calendar, size: 16, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                  Text(
                    AppFormatters.formatDate(date),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stol filtri ────────────────────────────────────────────
class _TableFilterRow extends StatelessWidget {
  final List<TableModel> tables;
  final int? selectedId;
  final ValueChanged<int?> onSelect;

  const _TableFilterRow({required this.tables, required this.selectedId, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: Text(s.allTables),
            selected: selectedId == null,
            onSelected: (_) => onSelect(null),
          ),
          const SizedBox(width: 8),
          ...tables.map(
            (t) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(t.name),
                selected: selectedId == t.id,
                onSelected: (_) => onSelect(selectedId == t.id ? null : t.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Girdeji jemleýji kartasy ────────────────────────────────
class _RevenueSummaryCard extends StatelessWidget {
  final double revenue;
  final DateTime from;
  final DateTime to;

  const _RevenueSummaryCard({required this.revenue, required this.from, required this.to});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    final sameDay = from.day == to.day && from.month == to.month && from.year == to.year;

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
            style: TextStyle(color: scheme.onPrimary.withAlpha(204), fontSize: 13, fontWeight: FontWeight.w500), // 0.8 * 255
          ),
          const SizedBox(height: 4),
          Text(
            '${AppFormatters.formatPriceRaw(revenue)} ${s.tmt}',
            style: TextStyle(color: scheme.onPrimary, fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -1),
          ),
          const SizedBox(height: 4),
          Text(
            s.totalRevenue,
            style: TextStyle(color: scheme.onPrimary.withAlpha(179), fontSize: 14), // 0.7 * 255
          ),
        ],
      ),
    );
  }
}

class _RevenueSkeleton extends StatelessWidget {
  const _RevenueSkeleton();

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

// ─── Taryh ýazgysy tile (Reports) ───────────────────────────
class _ReportLogTile extends StatelessWidget {
  final HistoryLogModel log;
  const _ReportLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withAlpha(102)), // 0.4 * 255
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      log.playerName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(log.tableName, style: Theme.of(context).textTheme.labelMedium),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${log.sessionCode}  ·  ${AppFormatters.formatDateTime(log.startTime)}  →  ${AppFormatters.formatTime(log.endTime)}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          Text(
            AppFormatters.formatPrice(log.totalPrice, S.of(context).tmt),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 15,
              color: scheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
