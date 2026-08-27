import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/models/table_model.dart';

class TablesHeader extends StatelessWidget {
  final AsyncValue<List<TableModel>> tablesAsync;
  const TablesHeader({super.key, required this.tablesAsync});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Padding(
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
    );
  }
}
