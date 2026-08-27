import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';

/// Başlangyç we tamamlanýan wagt: sene + sagat
class ReservationTimeRangeRow extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<DateTime> onEndChanged;

  const ReservationTimeRangeRow({
    super.key,
    required this.start,
    required this.end,
    required this.onStartChanged,
    required this.onEndChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Row(
      children: [
        Expanded(
          child: _DateTimeColumn(
            label: s.reservationStartsAt,
            value: start,
            onChanged: onStartChanged,
          ),
        ),
        Icon(
          Icons.arrow_forward,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        Expanded(
          child: _DateTimeColumn(
            label: s.reservationEndsAt,
            value: end,
            onChanged: onEndChanged,
          ),
        ),
      ],
    );
  }
}

class _DateTimeColumn extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const _DateTimeColumn({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    // Diňe şu gün we geljek. Köne bron redaktirlenende `value` geçen
    // wagt bolup biler — şonda başlangyç senäni çäge çenli süýşürýäris.
    final first = AppFormatters.startOfDay(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: value.isBefore(first) ? first : value,
      firstDate: first,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    onChanged(
      DateTime(picked.year, picked.month, picked.day, value.hour, value.minute),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(value),
    );
    if (picked == null) return;
    onChanged(
      DateTime(value.year, value.month, value.day, picked.hour, picked.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return Column(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        TextButton(
          onPressed: () => _pickDate(context),
          child: Text(s.shortDateLabel(value)),
        ),
        TextButton(
          onPressed: () => _pickTime(context),
          child: Text(
            AppFormatters.formatTime(value),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
