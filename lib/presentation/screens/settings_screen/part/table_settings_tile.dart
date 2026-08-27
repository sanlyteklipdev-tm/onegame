import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/models/table_model.dart';

// ─── Stol sazlamalary tile ───────────────────────────────────
class TableSettingsTile extends StatelessWidget {
  final TableModel table;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TableSettingsTile({
    super.key,
    required this.table,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withAlpha(102)),
      ),
      child: Row(
        children: [
          // Ýagdaý indikatoru
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: table.isActive ? scheme.primary : scheme.outline,
              shape: BoxShape.circle,
            ),
          ),

          // Maglumat
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  table.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
                Text(
                  '${table.pricePerHour.toStringAsFixed(1)} ${S.of(context).perHourShort}'
                  '${table.maxUsers != null ? "  ·  Max ${table.maxUsers}" : ""}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),

          // Düwmeler
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(CupertinoIcons.pencil),
                iconSize: 20,
                color: scheme.onSurfaceVariant,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(CupertinoIcons.trash),
                iconSize: 20,
                color: scheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
