import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'part/reservation_bottom_bar.dart';
import 'part/reservation_day_header.dart';
import 'part/reservation_table_filter.dart';
import 'part/reservation_timeline.dart';

class ReservationsScreen extends ConsumerWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: Column(
          children: [
            const ReservationDayHeader(),
            const ReservationTableFilter(),
            const Divider(height: 1),
            const Expanded(child: ReservationTimeline()),
            const ReservationBottomBar(),
          ],
        ),
      ),
    );
  }
}
