import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/models/reservation_model.dart';
import 'reservation_form_actions.dart';
import 'reservation_form_pickers.dart';
import 'reservation_save_action.dart';
import 'reservation_time_range_row.dart';

class ReservationFormSheet extends ConsumerStatefulWidget {
  final ReservationModel? existing;
  final DateTime? initialStart;

  const ReservationFormSheet({super.key, this.existing, this.initialStart});

  @override
  ConsumerState<ReservationFormSheet> createState() =>
      _ReservationFormSheetState();
}

class _ReservationFormSheetState extends ConsumerState<ReservationFormSheet> {
  late final TextEditingController _titleCtrl;
  late DateTime _start;
  late DateTime _end;
  int? _tableId;
  int? _customerId;
  int? _employeeId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _titleCtrl = TextEditingController(text: existing?.title ?? '');
    _tableId = existing?.tableId;
    _customerId = existing?.customerId;
    _employeeId = existing?.employeeId;
    _start = existing?.startTime ?? widget.initialStart ?? DateTime.now();
    _end = existing?.endTime ?? _start.add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    setState(() => _isSaving = true);

    // finally — garaşylmadyk ýalňyşlykda-da düwme spinnerde galmasyn
    try {
      final ok = await submitReservation(
        context: context,
        ref: ref,
        existing: widget.existing,
        tableId: _tableId,
        title: _titleCtrl.text.trim(),
        customerId: _customerId,
        employeeId: _employeeId,
        start: _start,
        end: _end,
      );
      if (ok && mounted) navigator.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Başlangyç süýşende dowamlylygy saklaýarys
  void _onStartChanged(DateTime dt) {
    setState(() {
      final span = _end.difference(_start);
      _start = dt;
      _end = dt.add(span.isNegative ? const Duration(hours: 1) : span);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset + 16,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleCtrl,
            autofocus: widget.existing == null,
            textCapitalization: TextCapitalization.words,
            style: Theme.of(context).textTheme.headlineSmall,
            decoration: InputDecoration(
              hintText: s.reservationName,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
          const Divider(),
          ReservationTablePicker(
            tableId: _tableId,
            onChanged: (id) => setState(() => _tableId = id),
          ),
          ReservationCustomerPicker(
            customerId: _customerId,
            onChanged: (customer) => setState(() {
              _customerId = customer?.id;
              if (customer != null) _titleCtrl.text = customer.name;
            }),
          ),
          ReservationEmployeePicker(
            employeeId: _employeeId,
            onChanged: (id) => setState(() => _employeeId = id),
          ),
          const Divider(),
          ReservationTimeRangeRow(
            start: _start,
            end: _end,
            onStartChanged: _onStartChanged,
            onEndChanged: (dt) => setState(() => _end = dt),
          ),
          const Divider(),
          const ReservationReminderNote(),
          const SizedBox(height: 16),
          ReservationFormActions(isSaving: _isSaving, onSave: _save),
        ],
      ),
    );
  }
}
