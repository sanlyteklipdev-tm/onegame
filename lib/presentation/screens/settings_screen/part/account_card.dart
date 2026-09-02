import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/data_source.dart';
import '../../../providers/auth_providers.dart';
import '../../../widgets/sign_out_action.dart';

/// Kim girdi we ulgamdan çykmak düwmesi.
///
/// Isar rejiminde giriş ýok — şonuň üçin karta düýbünden görkezilmeýär.
class AccountCard extends ConsumerWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!DataSourceConfig.usePostgres) return const SizedBox.shrink();

    final user = ref.watch(authProvider);
    if (user == null) return const SizedBox.shrink();

    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              child: Icon(
                CupertinoIcons.person_fill,
                size: 20,
                color: scheme.onPrimaryContainer,
              ),
            ),
            title: Text(user.displayName),
            subtitle: Text(
              '${user.username}  ·  ${s.roleLabel(user.role)}',
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              CupertinoIcons.square_arrow_right,
              size: 20,
              color: scheme.error,
            ),
            title: Text(s.signOut, style: TextStyle(color: scheme.error)),
            onTap: () => confirmSignOut(context, ref),
          ),
        ],
      ),
    );
  }
}
