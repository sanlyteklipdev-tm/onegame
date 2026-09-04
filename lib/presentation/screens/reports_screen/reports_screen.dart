import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import 'part/device_filter_row.dart';
import 'part/report_filters_section.dart';
import 'part/report_history_sliver.dart';
import 'part/report_revenue_card.dart';
import '../home_screen/part/home_drawer.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                child: Row(
                  children: [
                    const HomeMenuButton(),
                    Expanded(
                      child: Text(
                        s.reports,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Filtrler (çalt filtr, sene aralygy, stol) ──────
            const SliverToBoxAdapter(child: ReportFiltersSection()),
            const SliverToBoxAdapter(child: DeviceFilterRow()),

            // ── Jemi girdeji kartasy ───────────────────────────
            const SliverToBoxAdapter(child: ReportRevenueCard()),

            // ── Taryh sanawy ──────────────────────────────────
            const ReportHistorySliver(),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
