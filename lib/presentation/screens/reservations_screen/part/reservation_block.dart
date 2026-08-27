import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../data/models/reservation_model.dart';

/// Her stol öz reňki bilen tapawutlanýar
const List<Color> _tablePalette = [
  Color(0xFF3B82F6),
  Color(0xFF10B981),
  Color(0xFFA855F7),
  Color(0xFFF59E0B),
  Color(0xFFEC4899),
  Color(0xFF06B6D4),
];

Color colorForTable(int tableId) =>
    _tablePalette[tableId.abs() % _tablePalette.length];

/// Şkaladaky bir bron bloky
class ReservationBlock extends StatelessWidget {
  final ReservationModel reservation;
  final String tableName;
  final double height;
  final VoidCallback onTap;

  const ReservationBlock({
    super.key,
    required this.reservation,
    required this.tableName,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorForTable(reservation.tableId);
    final isStarted = reservation.isStarted;
    final compact = height < 44;

    final timeRange =
        '${AppFormatters.formatTime(reservation.startTime)}'
        '–${AppFormatters.formatTime(reservation.endTime)}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(isStarted ? 80 : 46),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (isStarted) ...[
                  Icon(Icons.play_arrow_rounded, size: 13, color: color),
                  const SizedBox(width: 2),
                ],
                Expanded(
                  child: Text(
                    reservation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (!compact)
              Text(
                '$tableName · $timeRange',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color.withAlpha(217),
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
