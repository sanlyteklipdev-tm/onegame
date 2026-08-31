import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/device_name_service.dart';

/// Enjamyň ady — ýazgylarda "haýsy enjamdan" diýip görkezilýär
class DeviceNameTile extends StatefulWidget {
  const DeviceNameTile({super.key});

  @override
  State<DeviceNameTile> createState() => _DeviceNameTileState();
}

class _DeviceNameTileState extends State<DeviceNameTile> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: DeviceNameService.current);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    FocusScope.of(context).unfocus();

    await DeviceNameService.setName(_ctrl.text);
    if (!mounted) return;

    setState(() {});
    messenger.showSnackBar(
      SnackBar(
        content: Text(s.deviceNameSaved),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    final changed = _ctrl.text.trim() != DeviceNameService.current;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.device_desktop,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                s.thisDeviceName,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ctrl,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              hintText: s.deviceNameHint,
              isDense: true,
              suffixIcon: changed
                  ? IconButton(
                      icon: const Icon(CupertinoIcons.checkmark_alt, size: 20),
                      color: scheme.primary,
                      onPressed: _save,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            s.deviceNameExplain,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
