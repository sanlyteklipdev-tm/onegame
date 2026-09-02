import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import 'part/account_card.dart';
import 'part/appearance_card.dart';
import 'part/database_card.dart';
import 'part/manage_tables_section.dart';
import 'part/printer_settings_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Başlyk ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Text(
                  s.settings,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // ── Hasap ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  s.account,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: AccountCard()),

            // ── Daşky görnüş (Tema we Dil) ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Text(
                  s.appearance,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: AppearanceCard()),

            // ── Printer sazlamalary ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Text(
                  'Printer sazlamalary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            SliverToBoxAdapter(child: PrinterSettingsCard()),

            // ── Maglumat bazasy ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Text(
                  s.database,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: DatabaseCard()),

            // ── Stollar bölümi ─────────────────────────────────
            const ManageTablesSection(),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
