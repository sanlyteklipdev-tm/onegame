import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/data_source.dart';
import '../../../../data/remote/postgres_config.dart';
import '../../../../data/remote/postgres_service.dart';
import 'device_name_tile.dart';

class DatabaseCard extends StatefulWidget {
  const DatabaseCard({super.key});

  @override
  State<DatabaseCard> createState() => _DatabaseCardState();
}

class _DatabaseCardState extends State<DatabaseCard> {
  bool? _connected;
  bool _checking = false;

  Future<void> _check() async {
    setState(() => _checking = true);
    final ok = await PostgresService.ping();
    if (!mounted) return;
    setState(() {
      _connected = ok;
      _checking = false;
    });
  }

  String _statusSuffix(S s) {
    final connected = _connected;
    if (connected == null) return '';
    return connected ? ' · ${s.dbConnected}' : ' · ${s.dbNotConnected}';
  }

  IconData get _statusIcon => switch (_connected) {
    null => CupertinoIcons.question_circle,
    true => CupertinoIcons.checkmark_circle_fill,
    false => CupertinoIcons.xmark_circle_fill,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withAlpha(102)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(CupertinoIcons.cube_box, color: scheme.primary),
            title: Text(s.dbCurrentSource),
            subtitle: Text(
              DataSourceConfig.usePostgres ? s.dbPostgres : s.dbLocalIsar,
            ),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Icon(
              _statusIcon,
              color: switch (_connected) {
                null => scheme.onSurfaceVariant,
                true => Colors.green,
                false => scheme.error,
              },
            ),
            title: Text(s.dbCheckConnection),
            subtitle: Text(
              '${PostgresConfig.effectiveHost}:${PostgresConfig.port}'
              ' · ${PostgresConfig.database}${_statusSuffix(s)}',
            ),
            trailing: _checking
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(CupertinoIcons.refresh),
                    onPressed: _check,
                  ),
          ),
          const Divider(height: 1, indent: 56),
          const DeviceNameTile(),
        ],
      ),
    );
  }
}
