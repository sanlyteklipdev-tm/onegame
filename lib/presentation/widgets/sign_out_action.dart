import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/services/worker_notification_sync.dart';
import '../providers/auth_providers.dart';
import '../screens/sign_in_screen/sign_in_screen.dart';

/// Tassyklama soraýar we ulgamdan çykýar.
/// Işgäriň ekranynda-da, sazlamalarda-da şu ulanylýar.
Future<void> confirmSignOut(BuildContext context, WidgetRef ref) async {
  final s = S.of(context);
  final navigator = Navigator.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(s.signOut),
      content: Text(s.signOutConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(s.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(s.signOut),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  // Öňki adamyň duýduryşlary indiki girene barmaly däl
  await WorkerNotificationSync.clear();
  await ref.read(authProvider.notifier).signOut();
  navigator.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const SignInScreen()),
    (route) => false,
  );
}
