import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../providers/providers.dart';
import '../../../widgets/receipt_dialog.dart';
import 'report_log_tile.dart';

class ReportHistorySliver extends ConsumerWidget {
  const ReportHistorySliver({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(filteredHistoryProvider);
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(s.history, style: Theme.of(context).textTheme.titleMedium),
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
                          color: scheme.onSurfaceVariant.withAlpha(77),
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
                child: ReportLogTile(log: logs[i]),
              ),
            );
          },
        ),
      ],
    );
  }
}
