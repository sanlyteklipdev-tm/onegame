import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';

class EmptyTablesView extends StatelessWidget {
  final VoidCallback onAdd;
  const EmptyTablesView({super.key, required this.onAdd});

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
              color: scheme.onSurfaceVariant.withAlpha(77),
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
