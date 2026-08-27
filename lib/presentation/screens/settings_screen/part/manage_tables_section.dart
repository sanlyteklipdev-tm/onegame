import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/models/table_model.dart';
import '../../../providers/providers.dart';
import '../../../widgets/add_table_sheet.dart';
import 'table_settings_tile.dart';

// ─── Stollar bölümi ─────────────────────────────────────────
class ManageTablesSection extends ConsumerWidget {
  const ManageTablesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(tablesStreamProvider);
    final s = S.of(context);

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.manageTable,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton.icon(
                  onPressed: () => _showAddTable(context),
                  icon: const Icon(CupertinoIcons.add, size: 16),
                  label: Text(s.add),
                ),
              ],
            ),
          ),
        ),
        tablesAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverToBoxAdapter(child: Text('$e')),
          data: (tables) {
            if (tables.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      s.emptyList,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
              );
            }

            return SliverList.builder(
              itemCount: tables.length,
              itemBuilder: (ctx, i) {
                final table = tables[i];
                return TableSettingsTile(
                  table: table,
                  onEdit: () => _showEditTable(context, table),
                  onDelete: () => _confirmDelete(context, ref, table),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showAddTable(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddTableSheet(),
    );
  }

  void _showEditTable(BuildContext context, TableModel table) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddTableSheet(editingTable: table),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, TableModel table) {
    final s = S.of(context);
    if (table.status == TableStatus.active) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.tableActiveError(table.name)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteTable),
        content: Text(s.tableDeleteConfirm(table.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(tableNotifierProvider.notifier).deleteTable(table.id);
            },
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }
}
