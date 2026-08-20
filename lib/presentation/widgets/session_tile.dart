import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/price_calculator.dart';
import '../../data/models/player_session_model.dart';
import '../providers/providers.dart';

class SessionTile extends ConsumerWidget {
  final PlayerSessionModel session;
  final double pricePerHour;
  final int activeCount;
  final VoidCallback onStop;

  const SessionTile({
    super.key,
    required this.session,
    required this.pricePerHour,
    required this.activeCount,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(timerProvider); // Her sekuntda täzelen
    final scheme = Theme.of(context).colorScheme;

    final now = DateTime.now();
    final duration = now.difference(session.startTime);
    final rawCost = PriceCalculator.currentSessionCost(
      accumulatedCost: session.accumulatedCost,
      lastCheckpointTime: session.lastCheckpointTime,
      pricePerHour: pricePerHour,
      currentActiveCount: activeCount,
    );
    final discount = session.discountPercentage;
    final currentCost = rawCost - (rawCost * discount / 100.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.primary.withAlpha(38)), // 0.15 * 255
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Ýokarky setir: at, kod, STOP ────────────────
          Row(
            children: [
              // Adam ikony
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _initials(session.playerName),
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // At we kod
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            session.playerName,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (discount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(30),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '-${discount.toStringAsFixed(0)}%',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.number,
                          size: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                        Text(
                          session.sessionCode,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                fontFamily: 'monospace',
                                letterSpacing: 0.5,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // STOP düwmesi
              _StopButton(onStop: onStop),
            ],
          ),

          const SizedBox(height: 12),

          // ── Aşakky setir: timer, baha ────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withAlpha(128), // 0.5 * 255
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // Timer
                Icon(CupertinoIcons.timer, size: 14, color: scheme.primary),
                const SizedBox(width: 6),
                Text(
                  AppFormatters.formatDuration(duration),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    color: scheme.primary,
                  ),
                ),

                const Spacer(),

                // Bildiriş sazlamagy (Reminder)
                _ReminderAction(session: session),
                const SizedBox(width: 12),

                // Häzirki baha
                Text(
                  AppFormatters.formatPrice(currentCost, S.of(context).tmt),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _ReminderAction extends ConsumerWidget {
  final PlayerSessionModel session;
  const _ReminderAction({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isActive = session.reminderMinutes != null;

    return PopupMenuButton<int?>(
      initialValue: session.reminderMinutes,
      onSelected: (minutes) {
        ref.read(sessionNotifierProvider.notifier).updateReminder(session.id, minutes);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: null, child: Text(s.noReminder)),
        const PopupMenuDivider(),
        PopupMenuItem(value: 15, child: Text(s.min15)),
        PopupMenuItem(value: 30, child: Text(s.min30)),
        PopupMenuItem(value: 45, child: Text(s.min45)),
        PopupMenuItem(value: 60, child: Text(s.h1)),
        PopupMenuItem(value: 90, child: Text(s.h1_5)),
        PopupMenuItem(value: 120, child: Text(s.h2)),
        PopupMenuItem(value: 180, child: Text(s.h3)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? scheme.primary.withAlpha(25) : Colors.transparent, // 0.1 * 255
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? scheme.primary.withAlpha(77) : scheme.outlineVariant, // 0.3 * 255
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? CupertinoIcons.bell_fill : CupertinoIcons.bell,
              size: 14,
              color: isActive ? scheme.primary : scheme.onSurfaceVariant,
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              Text(
                '${session.reminderMinutes}m',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: scheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


// ─── STOP düwmesi ───────────────────────────────────────────
class _StopButton extends StatelessWidget {
  final VoidCallback onStop;
  const _StopButton({required this.onStop});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onStop,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: scheme.error.withAlpha(25), // 0.1 * 255
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.error.withAlpha(77)), // 0.3 * 255
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.stop_circle, size: 16, color: scheme.error),
            const SizedBox(width: 6),
            Text(
              S.of(context).stop,
              style: TextStyle(
                color: scheme.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
