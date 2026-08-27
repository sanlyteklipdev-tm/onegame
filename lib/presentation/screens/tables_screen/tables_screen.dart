import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/table_model.dart';
import '../../providers/providers.dart';
import '../../widgets/table_card.dart';
import '../../widgets/add_table_sheet.dart';
import '../table_detail_screen/table_detail_screen.dart';
import 'part/empty_tables_view.dart';
import 'part/no_search_result_view.dart';
import 'part/table_search_field.dart';
import 'part/tables_error_view.dart';
import 'part/tables_header.dart';

class TablesScreen extends ConsumerStatefulWidget {
  const TablesScreen({super.key});

  @override
  ConsumerState<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends ConsumerState<TablesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _crossAxisCount(double width) {
    if (width >= 1400) return 6;
    if (width >= 1100) return 5;
    if (width >= 850) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final tablesAsync = ref.watch(tablesStreamProvider);
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TablesHeader(tablesAsync: tablesAsync),
            const SizedBox(height: 12),
            TableSearchField(
              controller: _searchController,
              hasQuery: _searchQuery.isNotEmpty,
            ),
            const SizedBox(height: 12),

            // ── Tables grid ─────────────────────────────────
            Expanded(
              child: tablesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => TablesErrorView(error: err.toString()),
                data: (tables) {
                  // Gözleg süzgüji
                  final filtered = _searchQuery.isEmpty
                      ? tables
                      : tables
                            .where(
                              (t) =>
                                  t.name.toLowerCase().contains(_searchQuery),
                            )
                            .toList();

                  if (tables.isEmpty) {
                    return EmptyTablesView(
                      onAdd: () => _showAddTable(context, ref),
                    );
                  }

                  if (filtered.isEmpty) {
                    return NoSearchResultView(query: _searchController.text);
                  }

                  final crossAxis = _crossAxisCount(screenWidth);
                  return RefreshIndicator(
                    onRefresh: () async => ref.refresh(tablesStreamProvider),
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxis,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        // >1 — kart beýikliginden giň, ýagny gönüburçluk
                        childAspectRatio: crossAxis >= 3 ? 1.45 : 1.3,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, i) {
                        final table = filtered[i];
                        return TableCard(
                          table: table,
                          onTap: () => _openTable(context, table),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ── FAB — Stol goş ──────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTable(context, ref),
        icon: const Icon(CupertinoIcons.add),
        label: Text(s.addTable),
      ),
    );
  }

  void _openTable(BuildContext context, TableModel table) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => TableDetailScreen(table: table)));
  }

  void _showAddTable(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddTableSheet(),
    );
  }
}
