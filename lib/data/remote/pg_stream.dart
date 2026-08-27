import 'dart:async';

/// Isar-daky `watch()` ýaly reaktiwlik PostgreSQL-de ýok — baza özi
/// üýtgeşme habaryny ibermeýär. Şonuň üçin sorag belli aralykda
/// gaýtalanýar.
///
/// Soňra muny LISTEN/NOTIFY-a geçirip bolar: tablisalara trigger goýup,
/// üýtgände habar ibermek. Şonda garaşmak we artykmaç sorag aýrylýar.
Stream<T> pollingStream<T>(
  Future<T> Function() query, {
  Duration interval = const Duration(seconds: 2),
}) {
  late StreamController<T> controller;
  Timer? timer;
  var isRunning = false;

  Future<void> tick() async {
    // Öňki sorag gutarmadyk bolsa, üstünden geçmesin
    if (isRunning || controller.isClosed) return;
    isRunning = true;
    try {
      final data = await query();
      if (!controller.isClosed) controller.add(data);
    } catch (e, st) {
      if (!controller.isClosed) controller.addError(e, st);
    } finally {
      isRunning = false;
    }
  }

  controller = StreamController<T>(
    onListen: () {
      tick();
      timer = Timer.periodic(interval, (_) => tick());
    },
    onCancel: () {
      timer?.cancel();
      timer = null;
    },
  );

  return controller.stream;
}
