import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/price_calculator.dart';
import '../../data/models/table_model.dart';
import '../providers/providers.dart';

class TableCard extends ConsumerWidget {
  final TableModel table;
  final VoidCallback onTap;

  const TableCard({super.key, required this.table, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAsync = ref.watch(activeSessionsProvider(table.id));
    ref.watch(timerProvider); // Real-time täzelenme
    final scheme = Theme.of(context).colorScheme;
    final isActive = table.status == TableStatus.active;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isActive ? scheme.primaryContainer : scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive
                ? scheme.primary.withAlpha(77) // 0.3 * 255
                : scheme.outlineVariant.withAlpha(128), // 0.5 * 255
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: scheme.primary.withAlpha(20), // 0.08 * 255
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ýokarky ──────────────────────────────────
              Row(
                children: [
                  // Ýagdaý ikonasy
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isActive
                          ? scheme.primary.withAlpha(38) // 0.15 * 255
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isActive
                          ? CupertinoIcons.play_circle_fill
                          : CupertinoIcons.circle,
                      size: 20,
                      color: isActive
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  // Oýunçy sany badge
                  activeAsync.when(
                    data: (sessions) {
                      if (sessions.isEmpty) return const SizedBox.shrink();
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.primary.withAlpha(31), // 0.12 * 255
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.person_2_fill,
                              size: 11,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${sessions.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (err, stack) => const SizedBox.shrink(),
                  ),
                ],
              ),

              const Spacer(),

              // ── Stol ady ──────────────────────────────────
              Text(
                table.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isActive
                      ? scheme.onPrimaryContainer
                      : scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              // ── Baha ýa-da aktiw baha ─────────────────────
              activeAsync.when(
                data: (sessions) {
                  if (!isActive || sessions.isEmpty) {
                    // Boş stol — sagatlyk bahasy
                    return Text(
                      '${table.pricePerHour.toStringAsFixed(0)} ${S.of(context).perHourShort}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isActive
                            ? scheme.onPrimaryContainer.withAlpha(179) // 0.7 * 255
                            : scheme.onSurfaceVariant,
                      ),
                    );
                  }

                  // Aktiw stol — häzirki umumy baha
                  double total = 0;
                  for (final s in sessions) {
                    total += PriceCalculator.currentSessionCost(
                      accumulatedCost: s.accumulatedCost,
                      lastCheckpointTime: s.lastCheckpointTime,
                      pricePerHour: table.pricePerHour,
                      currentActiveCount: sessions.length,
                    );
                  }
                  return Text(
                    '${AppFormatters.formatPriceRaw(total)} ${S.of(context).tmt}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (e, stack) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 4),

              // ── Ýagdaý teksti ─────────────────────────────
              Text(
                isActive ? S.of(context).active : S.of(context).available,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: isActive
                      ? scheme.primary
                      : scheme.onSurfaceVariant.withAlpha(153), // 0.6 * 255
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
