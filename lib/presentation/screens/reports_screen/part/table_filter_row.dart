import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/models/table_model.dart';

class TableFilterRow extends StatelessWidget {
  final List<TableModel> tables;
  final int? selectedId;
  final ValueChanged<int?> onSelect;

  const TableFilterRow({
    super.key,
    required this.tables,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: Text(s.allTables),
            selected: selectedId == null,
            onSelected: (_) => onSelect(null),
          ),
          const SizedBox(width: 8),
          ...tables.map(
            (t) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(t.name),
                selected: selectedId == t.id,
                onSelected: (_) => onSelect(selectedId == t.id ? null : t.id),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
