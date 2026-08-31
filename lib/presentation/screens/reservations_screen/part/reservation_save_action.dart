import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/reservation_notifications.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/reservation_model.dart';
import '../../../providers/reservation_providers.dart';

/// Formadan gelen maglumatlary barlaýar, ýazdyrýar we duýduryşlary belleýär.
/// Şowly bolsa `true` gaýtarýar, ýalňyşlykda özi habar görkezýär.
Future<bool> submitReservation({
  required BuildContext context,
  required WidgetRef ref,
  required ReservationModel? existing,
  required int? tableId,
  required String title,
  required int? customerId,
  required int? employeeId,
  required int? serviceId,
  required DateTime start,
  required DateTime end,
}) async {
  final s = S.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final errorColor = Theme.of(context).colorScheme.error;

  void showError(String text) => messenger.showSnackBar(
    SnackBar(content: Text(text), backgroundColor: errorColor),
  );

  if (tableId == null) {
    showError(s.selectTableFirst);
    return false;
  }
  if (title.isEmpty) {
    showError(s.enterName);
    return false;
  }
  // Hyzmat hökman saýlanmaly
  if (serviceId == null) {
    showError(s.selectServiceFirst);
    return false;
  }
  // Geçen wagta bron döretmek ýa-da bar bolan brony geçen wagta süýşürmek
  // gadagan. Wagty eýýäm gelen bronyň beýleki meýdanlaryny welin
  // (meselem adyny) düzedip bolýar.
  final startMoved =
      existing == null || !existing.startTime.isAtSameMomentAs(start);
  if (startMoved && start.isBefore(DateTime.now())) {
    showError(s.reservationInPast);
    return false;
  }

  try {
    final model = existing ?? ReservationModel();
    if (existing == null) {
      model.status = ReservationStatus.pending;
      model.createdAt = DateTime.now();
    }
    model
      ..tableId = tableId
      ..title = title
      ..customerId = customerId
      ..employeeId = employeeId
      ..serviceId = serviceId
      ..startTime = start
      ..endTime = end;

    final id = await ref.read(reservationNotifierProvider.notifier).save(model);
    final tableName = ref.read(tableNamesProvider)[tableId] ?? '';

    // Bron eýýäm ýazyldy — duýduryş bellenmese-de ýazgy ýitmeli däl
    try {
      await ReservationNotifications.schedule(
        reservationId: id,
        startTime: start,
        soonTitle: s.reservationReminderSoonTitle,
        soonBody: s.reservationReminderSoonBody(
          title,
          tableName,
          AppFormatters.formatTime(start),
        ),
        startTitle: s.reservationReminderNowTitle,
        startBody: s.reservationReminderNowBody(title, tableName),
      );
    } catch (e) {
      dev.log('Reservation reminder schedule failed: $e');
    }
    return true;
  } on InvalidReservationRangeException {
    showError(s.reservationEndBeforeStart);
  } on ReservationOverlapException catch (e) {
    showError(s.reservationOverlapError(e.tableName));
  }
  return false;
}
