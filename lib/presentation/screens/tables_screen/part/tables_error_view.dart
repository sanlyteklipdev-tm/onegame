import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';

class TablesErrorView extends StatelessWidget {
  final String error;
  const TablesErrorView({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          '${s.errorPrefix}: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
