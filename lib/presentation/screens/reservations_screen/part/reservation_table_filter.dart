import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../providers/providers.dart';
import '../../../providers/reservation_providers.dart';
import 'reservation_block.dart';

/// «Ähli stollar» + her stol üçin süzgüç çipleri
class ReservationTableFilter extends ConsumerWidget {
  const ReservationTableFilter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(tablesStreamProvider);
    final selected = ref.watch(reservationTableFilterProvider);
    final notifier = ref.read(reservationTableFilterProvider.notifier);
    final s = S.of(context);

    return tablesAsync.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (tables) {
        if (tables.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(s.allTables),
                  selected: selected == null,
                  onSelected: (_) => notifier.select(null),
                ),
              ),
              ...tables.map((t) {
                final color = colorForTable(t.id);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: CircleAvatar(backgroundColor: color, radius: 5),
                    label: Text(t.name),
                    selected: selected == t.id,
                    onSelected: (_) =>
                        notifier.select(selected == t.id ? null : t.id),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
