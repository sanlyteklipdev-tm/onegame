import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/price_calculator.dart';
import '../../data/models/player_session_model.dart';
import '../../data/models/history_log_model.dart';
import '../../data/models/table_model.dart';
import '../providers/providers.dart';
import '../widgets/session_tile.dart';
import '../widgets/checkout_sheet.dart';
import '../widgets/add_session_sheet.dart';
import '../widgets/close_table_sheet.dart';

class TableDetailScreen extends ConsumerWidget {
  final TableModel table;
  const TableDetailScreen({super.key, required this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeSessionsProvider(table.id));
    final historyAsync = ref.watch(tableHistoryProvider(table.id));
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(table.name),
            Text(
              '${AppFormatters.formatPrice(table.pricePerHour, s.tmt)} ${s.perHour}',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: scheme.primary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: activeAsync.when(
              data: (sessions) => _StatusChip(
                isActive: sessions.isNotEmpty,
                count: sessions.length,
              ),
              loading: () => const SizedBox.shrink(),
              error: (err, stack) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),

      body: activeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (activeSessions) {
          return CustomScrollView(
            slivers: [
              // ── Jemi baha kartasy ──────────────────────────
              if (activeSessions.isNotEmpty)
                SliverToBoxAdapter(
                  child: _TotalCostCard(
                    sessions: activeSessions,
                    pricePerHour: table.pricePerHour,
                    onCloseTable: () => _showCloseTable(context, ref, activeSessions),
                  ),
                ),

              // ── Aktiw sessiýalar ───────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        s.activePlayers,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      if (activeSessions.isNotEmpty)
                        _PlayerCountBadge(count: activeSessions.length),
                    ],
                  ),
                ),
              ),

              if (activeSessions.isEmpty)
                SliverToBoxAdapter(
                  child: _EmptySessionsHint(
                    onAdd: () => _showAddSession(context, ref),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: activeSessions.length,
                  itemBuilder: (ctx, i) {
                    final session = activeSessions[i];
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: SessionTile(
                        session: session,
                        pricePerHour: table.pricePerHour,
                        activeCount: activeSessions.length,
                        onStop: () => _showCheckout(
                          context,
                          ref,
                          session,
                          activeSessions.length,
                        ),
                      ),
                    );
                  },
                ),

              // ── Soňky hereketler (taryh) ──────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                  child: Text(
                    s.recentActions,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),

              historyAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(child: Text('$e')),
                data: (logs) {
                  if (logs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        child: Text(
                          s.noFinishedSessions,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    );
                  }
                  return SliverList.builder(
                    itemCount: logs.length,
                    itemBuilder: (ctx, i) => _HistoryLogTile(log: logs[i]),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),

      // ── FAB — Oýunçy goş ──────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSession(context, ref),
        icon: const Icon(CupertinoIcons.person_badge_plus),
        label: Text(s.addPlayer),
      ),
    );
  }

  void _showAddSession(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddSessionSheet(tableId: table.id),
    );
  }

  void _showCheckout(
    BuildContext context,
    WidgetRef ref,
    PlayerSessionModel session,
    int activeCount,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      builder: (_) => CheckoutSheet(
        session: session,
        table: table,
        activeCount: activeCount,
      ),
    );
  }

  void _showCloseTable(BuildContext context, WidgetRef ref, List<PlayerSessionModel> activeSessions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      builder: (_) => CloseTableSheet(
        table: table,
        activeSessions: activeSessions,
      ),
    );
  }
}

// ─── Jemi baha kartasy (real-time) ───────────────────────────
class _TotalCostCard extends ConsumerWidget {
  final List<PlayerSessionModel> sessions;
  final double pricePerHour;
  final VoidCallback onCloseTable;

  const _TotalCostCard({required this.sessions, required this.pricePerHour, required this.onCloseTable});

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
                      color: scheme.onPrimaryContainer.withAlpha(179), // 0.7 * 255
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppFormatters.formatPriceRaw(totalCost)} ${s.tmt}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                      color: scheme.onPrimaryContainer.withAlpha(179), // 0.7 * 255
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
              icon: const Icon(CupertinoIcons.rectangle_stack_person_crop_fill, size: 18),
              label: Text(s.closeTotalTable),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ýagdaý çipi ────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final bool isActive;
  final int count;
  const _StatusChip({required this.isActive, required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: isActive ? scheme.primary : scheme.outline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? s.personCount(count) : s.available,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isActive ? scheme.primary : scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Oýunçy sany badge ──────────────────────────────────────
class _PlayerCountBadge extends StatelessWidget {
  final int count;
  const _PlayerCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        s.personCount(count),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Boş sessiýa hint ──────────────────────────────────────
class _EmptySessionsHint extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptySessionsHint({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withAlpha(102), // 0.4 * 255
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withAlpha(128), // 0.5 * 255
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.person_2,
            size: 40,
            color: scheme.onSurfaceVariant.withAlpha(102), // 0.4 * 255
          ),
          const SizedBox(height: 8),
          Text(s.addPlayersHint, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

// ─── Taryh ýazgysy tile ─────────────────────────────────────
class _HistoryLogTile extends StatelessWidget {
  final HistoryLogModel log;
  const _HistoryLogTile({required this.log});

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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              CupertinoIcons.checkmark_circle,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.playerName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${log.sessionCode}  ·  ${S.of(context).durationReadable(log.duration)}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppFormatters.formatPrice(log.totalPrice, S.of(context).tmt),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                AppFormatters.formatTime(log.endTime),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
