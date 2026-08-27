import 'package:flutter/material.dart';

import 'reservation_layout.dart';

/// Sagat çyzyklary (doly) we ýarym sagat çyzyklary (nokatly)
class ReservationGridPainter extends CustomPainter {
  final Color lineColor;
  final Color dotColor;

  const ReservationGridPainter({
    required this.lineColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final solid = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    for (var h = 0; h <= 24; h++) {
      final y = h * kHourHeight;
      canvas.drawLine(Offset(kTimeGutter, y), Offset(size.width, y), solid);
    }

    final dotted = Paint()
      ..color = dotColor
      ..strokeWidth = 1;

    for (var h = 0; h < 24; h++) {
      final y = h * kHourHeight + kHourHeight / 2;
      var x = kTimeGutter;
      while (x < size.width) {
        canvas.drawLine(Offset(x, y), Offset(x + 3, y), dotted);
        x += 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant ReservationGridPainter old) =>
      old.lineColor != lineColor || old.dotColor != dotColor;
}

/// Çep tarapdaky sagat sanlary
class ReservationHourLabels extends StatelessWidget {
  const ReservationHourLabels({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        for (var h = 1; h < 24; h++)
          Positioned(
            top: h * kHourHeight - 8,
            left: 0,
            width: kTimeGutter - 10,
            child: Text(
              '$h',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}
