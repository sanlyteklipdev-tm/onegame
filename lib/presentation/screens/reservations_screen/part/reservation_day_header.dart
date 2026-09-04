import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../providers/reservation_providers.dart';
import '../../home_screen/part/home_drawer.dart';

/// Aý ady, gün sany, hepdäniň güni we günden-güne geçiş
class ReservationDayHeader extends ConsumerWidget {
  const ReservationDayHeader({super.key});

  /// Senenamany açyp, islendik güne geçmäge mümkinçilik berýär
  Future<void> _pickDate(
    BuildContext context,
    WidgetRef ref,
    DateTime current,
  ) async {
    // Diňe şu gün we geljek — geçen günlere bron edip bolmaýar
    final first = AppFormatters.startOfDay(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: current.isBefore(first) ? first : current,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    ref.read(selectedReservationDateProvider.notifier).setDate(picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(selectedReservationDateProvider);
    final notifier = ref.read(selectedReservationDateProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    final isToday = AppFormatters.isToday(date);
    final canGoBack = date.isAfter(AppFormatters.startOfDay(DateTime.now()));

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        children: [
          Row(
            children: [
              const HomeMenuButton(),
              IconButton(
                icon: const Icon(CupertinoIcons.chevron_left, size: 20),
                // Şu günden yza geçip bolmaýar
                onPressed: canGoBack ? notifier.previousDay : null,
              ),
              Expanded(
                child: Text(
                  s.monthShort(date.month),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.chevron_right, size: 20),
                onPressed: notifier.nextDay,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              // Basylanda senenama açylýar — islendik güne geçmek üçin
              InkWell(
                onTap: () => _pickDate(context, ref, date),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isToday ? scheme.primary : scheme.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: scheme.outlineVariant.withAlpha(102),
                          ),
                        ),
                        child: Text(
                          '${date.day}',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isToday
                                    ? scheme.onPrimary
                                    : scheme.onSurface,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        s.weekdayFull(date.weekday),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        CupertinoIcons.chevron_down,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (!isToday)
                TextButton(
                  onPressed: notifier.goToToday,
                  child: Text(s.today),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
