import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';

class EmptySessionsHint extends StatelessWidget {
  final VoidCallback onAdd;
  const EmptySessionsHint({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withAlpha(102),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scheme.outlineVariant.withAlpha(128),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.person_2,
            size: 40,
            color: scheme.onSurfaceVariant.withAlpha(102),
          ),
          const SizedBox(height: 8),
          Text(s.addPlayersHint, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
