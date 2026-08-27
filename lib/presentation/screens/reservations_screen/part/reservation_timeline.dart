import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/reservation_model.dart';
import '../../../providers/reservation_providers.dart';
import 'current_time_indicator.dart';
import 'reservation_block.dart';
import 'reservation_form_sheet.dart';
import 'reservation_detail_sheet.dart';
import 'reservation_grid_painter.dart';
import 'reservation_layout.dart';

/// Günüň sagat şkalasy we onuň üstündäki bron bloklary
class ReservationTimeline extends ConsumerStatefulWidget {
  const ReservationTimeline({super.key});

  @override
  ConsumerState<ReservationTimeline> createState() =>
      _ReservationTimelineState();
}

class _ReservationTimelineState extends ConsumerState<ReservationTimeline> {
  /// Açylanda häzirki wagt görünsin. `initialScrollOffset` ölçegler
  /// belli bolmanka hem işleýär — soň özi çäge çenli gysylýar.
  final ScrollController _controller = ScrollController(
    initialScrollOffset: (offsetForTime(DateTime.now()) - 150)
        .clamp(0.0, 24 * kHourHeight),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openSheet(Widget sheet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => sheet,
    );
  }

  /// Boş ýere basylanda şol wagt üçin bron açýar.
  /// Geçen wagt bolsa açmaýar-da, sebäbini habar berýär.
  void _onEmptySlotTap(DateTime day, double dy) {
    final tapped = timeFromOffset(day, dy);
    if (tapped.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).reservationInPast),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    _openSheet(ReservationFormSheet(initialStart: tapped));
  }

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(selectedReservationDateProvider);
    final reservations = ref
        .watch(visibleReservationsProvider)
        .maybeWhen(data: (r) => r, orElse: () => <ReservationModel>[]);
    final names = ref.watch(tableNamesProvider);
    final scheme = Theme.of(context).colorScheme;

    final slots = layoutReservations(reservations);
    final dayStart = DateTime(date.year, date.month, date.day);

    return SingleChildScrollView(
      controller: _controller,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final laneArea = constraints.maxWidth - kTimeGutter - 8;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapUp: (details) =>
                _onEmptySlotTap(date, details.localPosition.dy),
            child: SizedBox(
              height: 24 * kHourHeight,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ReservationGridPainter(
                        lineColor: scheme.outlineVariant.withAlpha(102),
                        dotColor: scheme.outlineVariant.withAlpha(64),
                      ),
                    ),
                  ),
                  const ReservationHourLabels(),
                  ...slots.map(
                    (slot) => _positionedBlock(slot, dayStart, laneArea, names),
                  ),
                  if (AppFormatters.isToday(date)) const CurrentTimeIndicator(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _positionedBlock(
    ReservationSlot slot,
    DateTime dayStart,
    double laneArea,
    Map<int, String> names,
  ) {
    final r = slot.reservation;
    const dayHeight = 24 * kHourHeight;

    double toOffset(DateTime t) =>
        (t.difference(dayStart).inMinutes / 60.0 * kHourHeight)
            .clamp(0.0, dayHeight);

    final top = toOffset(r.startTime);
    // Gije 00:00-dan geçýän bronlar günüň soňuna çenli kesilýär
    final height = (toOffset(r.endTime) - top).clamp(22.0, dayHeight - top);
    final laneWidth = laneArea / slot.columnCount;

    return Positioned(
      top: top + 1,
      left: kTimeGutter + 4 + slot.column * laneWidth,
      width: laneWidth - 4,
      height: height - 2,
      child: ReservationBlock(
        reservation: r,
        tableName: names[r.tableId] ?? '',
        height: height,
        onTap: () => _openSheet(ReservationDetailSheet(reservation: r)),
      ),
    );
  }
}
