import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/models/table_model.dart';
import '../../../providers/providers.dart';
import '../../../widgets/session_tile.dart';
import 'empty_sessions_hint.dart';
import 'history_log_tile.dart';
import 'player_count_badge.dart';
import 'table_detail_actions.dart';
import 'total_cost_card.dart';

class TableSessionsBody extends ConsumerWidget {
  final TableModel table;
  const TableSessionsBody({super.key, required this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeSessionsProvider(table.id));
    final historyAsync = ref.watch(tableHistoryProvider(table.id));
    final s = S.of(context);

    return activeAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (activeSessions) {
        return CustomScrollView(
          slivers: [
            // ── Jemi baha kartasy ──────────────────────────
            if (activeSessions.isNotEmpty)
              SliverToBoxAdapter(
                child: TotalCostCard(
                  sessions: activeSessions,
                  pricePerHour: table.pricePerHour,
                  onCloseTable: () =>
                      showCloseTableSheet(context, table, activeSessions),
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
                      PlayerCountBadge(count: activeSessions.length),
                  ],
                ),
              ),
            ),

            if (activeSessions.isEmpty)
              SliverToBoxAdapter(
                child: EmptySessionsHint(
                  onAdd: () => showAddSessionSheet(context, table),
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
                      onStop: () => showCheckoutSheet(
                        context,
                        table,
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
                  itemBuilder: (ctx, i) => HistoryLogTile(log: logs[i]),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        );
      },
    );
  }
}
