import '../../../../data/models/reservation_model.dart';

/// Bir sagadyň beýikligi (piksel)
const double kHourHeight = 64.0;

/// Çep tarapdaky sagat sanlary üçin giňlik
const double kTimeGutter = 52.0;

/// Bir bronyň şkaladaky ýerleşişi.
/// Dürli stollaryň bronlary wagt boýunça gabat gelip biler —
/// şonuň üçin gabat gelýänler ýanaşyk sütünlere bölünýär.
class ReservationSlot {
  final ReservationModel reservation;
  final int column;
  final int columnCount;

  const ReservationSlot({
    required this.reservation,
    required this.column,
    required this.columnCount,
  });
}

/// Gabat gelýän bronlary sütünlere paýlaýar.
List<ReservationSlot> layoutReservations(List<ReservationModel> items) {
  final sorted = [...items]
    ..sort((a, b) => a.startTime.compareTo(b.startTime));

  final result = <ReservationSlot>[];
  var cluster = <ReservationModel>[];
  DateTime? clusterEnd;

  void flushCluster() {
    if (cluster.isEmpty) return;

    final laneEnds = <DateTime>[];
    final laneOf = <int>[];

    for (final r in cluster) {
      var lane = -1;
      for (var i = 0; i < laneEnds.length; i++) {
        if (!laneEnds[i].isAfter(r.startTime)) {
          lane = i;
          break;
        }
      }
      if (lane == -1) {
        laneEnds.add(r.endTime);
        lane = laneEnds.length - 1;
      } else {
        laneEnds[lane] = r.endTime;
      }
      laneOf.add(lane);
    }

    for (var i = 0; i < cluster.length; i++) {
      result.add(
        ReservationSlot(
          reservation: cluster[i],
          column: laneOf[i],
          columnCount: laneEnds.length,
        ),
      );
    }

    cluster = [];
    clusterEnd = null;
  }

  for (final r in sorted) {
    final end = clusterEnd;
    if (end != null && !r.startTime.isBefore(end)) flushCluster();

    cluster.add(r);
    final current = clusterEnd;
    if (current == null || r.endTime.isAfter(current)) {
      clusterEnd = r.endTime;
    }
  }
  flushCluster();

  return result;
}

/// Günüň başyndan geçen wagta görä ýokardan uzaklyk
double offsetForTime(DateTime time) =>
    (time.hour + time.minute / 60.0) * kHourHeight;

/// Şkalada basylan ýere görä wagt (30 minutlyk ädimlere tegeleýär)
DateTime timeFromOffset(DateTime day, double dy) {
  final totalMinutes = (dy / kHourHeight) * 60.0;
  final rounded = (totalMinutes / 30).floor() * 30;
  final clamped = rounded.clamp(0, 23 * 60 + 30);
  return DateTime(day.year, day.month, day.day)
      .add(Duration(minutes: clamped));
}
