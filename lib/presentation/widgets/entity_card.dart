import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'device_chip.dart';

/// Müşderi, işgär we hyzmat sanawlarynyň umumy gönüburçluk karty.
/// Stol kartynyň gurluşyny gaýtalaýar: ýokarsy — bellikler,
/// aşagy — at we maglumat.
class EntityCard extends StatelessWidget {
  final String name;

  /// Sagky ýokarky bellik: kategoriýa, wezipe ýa-da baha
  final String? badge;

  /// Adyň aşagyndaky setir (telefon, baha, skidka…)
  final String? subtitle;

  final IconData icon;
  final String? deviceName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const EntityCard({
    super.key,
    required this.name,
    required this.icon,
    required this.onEdit,
    required this.onDelete,
    this.badge,
    this.subtitle,
    this.deviceName,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withAlpha(128)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 6, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ýokarky hatar: nyşan, bellik, düwmeler ──────
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 17, color: scheme.onSurfaceVariant),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 6),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                _IconAction(
                  icon: CupertinoIcons.pencil,
                  color: scheme.onSurfaceVariant,
                  onTap: onEdit,
                ),
                _IconAction(
                  icon: CupertinoIcons.trash,
                  color: scheme.error,
                  onTap: onDelete,
                ),
              ],
            ),

            const Spacer(),

            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            DeviceChip(deviceName: deviceName, dense: true),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}
