import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/table_model.dart';
import 'part/table_detail_actions.dart';
import 'part/table_detail_app_bar.dart';
import 'part/table_sessions_body.dart';

class TableDetailScreen extends ConsumerWidget {
  final TableModel table;
  const TableDetailScreen({super.key, required this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      appBar: TableDetailAppBar(table: table),
      body: TableSessionsBody(table: table),

      // ── FAB — Oýunçy goş ──────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddSessionSheet(context, table),
        icon: const Icon(CupertinoIcons.person_badge_plus),
        label: Text(s.addPlayer),
      ),
    );
  }
}
