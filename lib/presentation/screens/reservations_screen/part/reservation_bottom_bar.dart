import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../providers/reservation_providers.dart';
import 'reservation_form_sheet.dart';

/// Aşakdaky çalt goşmak setiri we «+» düwmesi
class ReservationBottomBar extends ConsumerWidget {
  const ReservationBottomBar({super.key});

  /// Saýlanan gün şu gün bolsa — indiki ýarym sagat, ýogsa 12:00
  DateTime _defaultStart(DateTime day) {
    if (!AppFormatters.isToday(day)) {
      return DateTime(day.year, day.month, day.day, 12);
    }
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day, now.hour);
    return now.minute < 30
        ? base.add(const Duration(minutes: 30))
        : base.add(const Duration(hours: 1));
  }

  void _openForm(BuildContext context, DateTime day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ReservationFormSheet(initialStart: _defaultStart(day)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedReservationDateProvider);
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openForm(context, date),
              child: Container(
                height: 48,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withAlpha(153),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  s.addBookingOn(s.shortDateLabel(date)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FloatingActionButton(
            heroTag: 'reservation-add',
            onPressed: () => _openForm(context, date),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
