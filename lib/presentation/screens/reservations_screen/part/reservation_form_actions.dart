import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';

/// Duýduryş barada düşündiriş setiri
class ReservationReminderNote extends StatelessWidget {
  const ReservationReminderNote({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(CupertinoIcons.bell, size: 18, color: scheme.onSurfaceVariant),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            S.of(context).reservationReminderInfo,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// «Ýatyr» we «Ýatda sakla» düwmeleri
class ReservationFormActions extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;

  const ReservationFormActions({
    super.key,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: isSaving ? null : onSave,
            child: isSaving
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(s.save),
          ),
        ),
      ],
    );
  }
}
