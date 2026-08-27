import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/notification_service.dart';

// ─── Bildiriş sazlamalary kartasy ───────────────────────────
class NotificationSettingsCard extends StatefulWidget {
  const NotificationSettingsCard({super.key});

  @override
  State<NotificationSettingsCard> createState() =>
      _NotificationSettingsCardState();
}

class _NotificationSettingsCardState extends State<NotificationSettingsCard> {
  bool? _isExactAlarmPermissionGranted;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await NotificationService().checkExactAlarmPermission();
    if (mounted) {
      setState(() {
        _isExactAlarmPermissionGranted = status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
            leading: Icon(CupertinoIcons.bell, color: scheme.primary),
            title: Text('Bildiriş rugsadyny barla'),
            subtitle: Text('Android 13+ üçin duýduruş rugsadyny sorar'),
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              final granted = await NotificationService().requestPermissions();
              if (!mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    granted
                        ? 'Bildiriş rugsadyny alyndy'
                        : 'Bildiriş rugsadyny berilmedi',
                  ),
                  backgroundColor: granted ? Colors.green : Colors.orange,
                ),
              );
            },
          ),
          Divider(height: 1, indent: 56),
          ListTile(
            leading: Icon(CupertinoIcons.speaker_2, color: scheme.primary),
            title: Text('Sesi barla'),
            subtitle: Text('Duýduruş sesiniň işleýändigini barlamak üçin'),
            trailing: Icon(
              CupertinoIcons.play_circle,
              size: 24,
              color: scheme.primary,
            ),
            onTap: () async {
              await NotificationService().showTestNotification();
            },
          ),
          Divider(height: 1, indent: 56),
          ListTile(
            leading: Icon(
              _isExactAlarmPermissionGranted == true
                  ? CupertinoIcons.checkmark_circle_fill
                  : CupertinoIcons.exclamationmark_circle_fill,
              color: _isExactAlarmPermissionGranted == true
                  ? Colors.green
                  : Colors.orange,
            ),
            title: Text('Takyk duýduruşlar (Exact Alarms)'),
            subtitle: Text(
              'Android 14+ üçin wajyp. Häzirki weziýet: ${_isExactAlarmPermissionGranted == true ? "Rugsat berlen" : "Rugsat berilmedik"}',
            ),
            trailing: Icon(CupertinoIcons.settings, size: 20),
            onTap: () async {
              await NotificationService().requestExactAlarmPermission();
              // Re-check after returning from settings
              Future.delayed(const Duration(seconds: 2), _checkPermissions);
            },
          ),
          if (_isExactAlarmPermissionGranted == false)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Üns beriň! Android 14+ (we Android 16) ulgamlarynda duýduruşlaryň wagtly-wagtynda gelmegi üçin "Matalar we duýduruşlar" (Alarms & Reminders) sazlamasyny açmalydygyny ýadyňyzdan çykarmaň.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.orange.shade900),
              ),
            ),
        ],
      ),
    );
  }
}
