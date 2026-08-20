import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onegame/core/services/notification_service.dart';

import '../../core/l10n/app_localizations.dart';
import '../../data/models/table_model.dart';
import '../providers/providers.dart';
import '../widgets/table_card.dart';
import '../widgets/add_table_sheet.dart';
import 'table_detail_screen.dart';

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
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.appTitle,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        tablesAsync.when(
                          data: (tables) {
                            final active = tables
                                .where((t) => t.status == TableStatus.active)
                                .length;
                            return Text(
                              s.activeTablesCount(active, tables.length),
                              style: Theme.of(context).textTheme.bodyMedium,
                            );
                          },
                          loading: () => const SizedBox.shrink(),
                          error: (err, stack) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Search Input ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: s.searchTableHint,
                  prefixIcon: const Icon(CupertinoIcons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            CupertinoIcons.clear_circled_solid,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest.withAlpha(
                    153,
                  ), // 0.6 * 255
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: scheme.outlineVariant.withAlpha(102), // 0.4 * 255
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: scheme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Tables grid ─────────────────────────────────
            Expanded(
              child: tablesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => _ErrorView(error: err.toString()),
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
                    return _EmptyTablesView(
                      onAdd: () => _showAddTable(context, ref),
                    );
                  }

                  if (filtered.isEmpty) {
                    return _NoSearchResultView(query: _searchController.text);
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
                        childAspectRatio: crossAxis >= 3 ? 0.92 : 0.88,
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

// ─── Gözleg netijesi ýok ────────────────────────────────────
class _NoSearchResultView extends StatelessWidget {
  final String query;
  const _NoSearchResultView({required this.query});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.search,
              size: 56,
              color: scheme.onSurfaceVariant.withAlpha(77), // 0.3 * 255
            ),
            const SizedBox(height: 16),
            Text(
              '"$query"',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              S.of(context).noSearchResult,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state ────────────────────────────────────────────
class _EmptyTablesView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyTablesView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.table,
              size: 72,
              color: scheme.onSurfaceVariant.withAlpha(77), // 0.3 * 255
            ),
            const SizedBox(height: 16),
            Text(
              s.noTables,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              s.noTablesHint,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(CupertinoIcons.add),
              label: Text(s.addTable),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationTestButton extends StatefulWidget {
  const NotificationTestButton({super.key});

  @override
  State<NotificationTestButton> createState() => _NotificationTestButtonState();
}

class _NotificationTestButtonState extends State<NotificationTestButton> {
  int _seconds = 0;
  Timer? _timer;

  void _startTest() async {
    if (_seconds > 0) return;

    final scheduledTime = DateTime.now().add(const Duration(seconds: 10));

    // Bildirişi meýilleşdirýäris
    await NotificationService().scheduleReminder(
      sessionId: 1000, // Test üçin ýörite ID
      title: "Test Bildiriş",
      body: "Bu 10 sekuntdan soň gelmeli barlaýyş habarydyr!",
      scheduledTime: scheduledTime,
    );

    if (!mounted) return;
    setState(() {
      _seconds = 10;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 1) {
        if (mounted) {
          setState(() {
            _seconds--;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _seconds = 0;
          });
        }
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _startTest,
          icon: const Icon(Icons.notifications_active),
          label: Text(
            _seconds > 0
                ? "Bildirişe galdy: $_seconds sek"
                : "Bildirişi barla (10 sek)",
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _seconds > 0 ? Colors.orange.shade100 : null,
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          '${s.errorPrefix}: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
