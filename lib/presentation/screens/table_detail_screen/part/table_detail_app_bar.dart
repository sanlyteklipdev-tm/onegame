import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/table_model.dart';
import '../../../providers/providers.dart';
import 'status_chip.dart';

class TableDetailAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final TableModel table;
  const TableDetailAppBar({super.key, required this.table});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeSessionsProvider(table.id));
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return AppBar(
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(table.name),
          Text(
            '${AppFormatters.formatPrice(table.pricePerHour, s.tmt)} ${s.perHour}',
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: scheme.primary),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: activeAsync.when(
            data: (sessions) => StatusChip(
              isActive: sessions.isNotEmpty,
              count: sessions.length,
            ),
            loading: () => const SizedBox.shrink(),
            error: (err, stack) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
