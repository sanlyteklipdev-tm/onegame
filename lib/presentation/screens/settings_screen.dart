import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/printer_service.dart';
import '../../data/models/table_model.dart';
import '../providers/providers.dart';
import '../widgets/add_table_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(tablesStreamProvider);
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    final currentTheme = ref.watch(themeModeProvider);
    final currentLang = ref.watch(appLanguageProvider);

    return Scaffold(
      backgroundColor: scheme.surfaceContainerLowest,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Başlyk ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Text(
                  s.settings,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // ── Daşky görnüş (Tema we Dil) ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  s.appearance,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.outlineVariant.withAlpha(102), // 0.4 * 255
                  ),
                ),
                child: Column(
                  children: [
                    // Tema saýlaýjy
                    _SettingsDropdown<ThemeMode>(
                      icon: CupertinoIcons.moon_stars,
                      title: s.theme,
                      value: currentTheme,
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(s.themeSystem),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(s.themeLight),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(s.themeDark),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          ref.read(themeModeProvider.notifier).setTheme(v);
                        }
                      },
                    ),
                    Divider(
                      height: 1,
                      color: scheme.outlineVariant.withAlpha(77), // 0.3 * 255
                    ),
                    // Dil saýlaýjy
                    _SettingsDropdown<AppLanguage>(
                      icon: CupertinoIcons.globe,
                      title: s.language,
                      value: currentLang,
                      items: AppLanguage.values.map((lang) {
                        return DropdownMenuItem(
                          value: lang,
                          child: Text(
                            lang.displayName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          ref.read(appLanguageProvider.notifier).setLanguage(v);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Printer sazlamalary (Printer) ───────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Text(
                  'Printer sazlamalary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),

            SliverToBoxAdapter(child: _PrinterSettingsCard()),

            // ── Bildiriş sazlamalary (Notifications) ───────────
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            //     child: Text(
            //       'Bildiriş sazlamalary',
            //       style: Theme.of(context).textTheme.titleMedium,
            //     ),
            //   ),
            // ),

            // SliverToBoxAdapter(
            //   child: _NotificationSettingsCard(),
            // ),

            // ── Stollar bölümi ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.manageTable,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddTable(context),
                      icon: const Icon(CupertinoIcons.add, size: 16),
                      label: Text(s.add),
                    ),
                  ],
                ),
              ),
            ),

            tablesAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(child: Text('$e')),
              data: (tables) {
                if (tables.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          s.emptyList,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  );
                }

                return SliverList.builder(
                  itemCount: tables.length,
                  itemBuilder: (ctx, i) {
                    final table = tables[i];
                    return _TableSettingsTile(
                      table: table,
                      onEdit: () => _showEditTable(context, table),
                      onDelete: () => _confirmDelete(context, ref, table),
                    );
                  },
                );
              },
            ),

            // ── Programma maglumatlary ─────────────────────────
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(20, 32, 20, 10),
            //     child: Text(
            //       s.aboutApp,
            //       style: Theme.of(context).textTheme.titleMedium,
            //     ),
            //   ),
            // ),

            // SliverToBoxAdapter(
            //   child: Container(
            //     margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            //     decoration: BoxDecoration(
            //       color: scheme.surface,
            //       borderRadius: BorderRadius.circular(16),
            //       border: Border.all(
            //         color: scheme.outlineVariant.withAlpha(102),
            //       ),
            //     ),
            //     child: Column(
            //       children: [
            //         _InfoTile(
            //           icon: CupertinoIcons.info_circle,
            //           title: s.version,
            //           value: '1.0.0',
            //         ),
            //         // Divider(
            //         //   height: 1,
            //         //   color: scheme.outlineVariant.withAlpha(77),
            //         // ),
            //         // _InfoTile(
            //         //   icon: CupertinoIcons.building_2_fill,
            //         //   title: s.appName,
            //         //   value: 'Billiard Timer',
            //         // ),
            //         Divider(
            //           height: 1,
            //           color: scheme.outlineVariant.withAlpha(77),
            //         ),
            //         _InfoTile(
            //           icon: CupertinoIcons.lock_shield,
            //           title: s.dataStorage,
            //           value: s.localOnly,
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  void _showAddTable(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const AddTableSheet(),
    );
  }

  void _showEditTable(BuildContext context, TableModel table) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddTableSheet(editingTable: table),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, TableModel table) {
    final s = S.of(context);
    if (table.status == TableStatus.active) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.tableActiveError(table.name)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteTable),
        content: Text(s.tableDeleteConfirm(table.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(tableNotifierProvider.notifier).deleteTable(table.id);
            },
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }
}

// ─── Printer sazlamalary kartasy ───────────────────────────
class _PrinterSettingsCard extends StatefulWidget {
  @override
  State<_PrinterSettingsCard> createState() => _PrinterSettingsCardState();
}

class _PrinterSettingsCardState extends State<_PrinterSettingsCard> {
  final PrinterService _printerService = PrinterService();
  List<BluetoothInfo> _devices = [];
  BluetoothInfo? _selectedDevice;
  bool _isConnected = false;
  bool _hasPermissions = true;

  @override
  void initState() {
    super.initState();
    _initPrinter();
  }

  Future<void> _initPrinter() async {
    final connected = await _printerService.isConnected();
    if (mounted) {
      setState(() {
        _isConnected = connected;
      });
    }

    final hasPerms = await _printerService.hasPermissions();
    if (mounted) setState(() => _hasPermissions = hasPerms);

    if (!hasPerms) return;

    final devices = await _printerService.getDevices();
    if (mounted) {
      setState(() {
        _devices = devices;
        // Fix for Dropdown assertion error: 
        // Ensure _selectedDevice still exists in the list (or it's the same instance)
        if (_selectedDevice != null) {
          final exists = _devices.any((d) => d.macAdress == _selectedDevice!.macAdress);
          if (!exists) {
            _selectedDevice = null;
          } else {
            // Update reference to the new instance from the list to avoid object mismatch
            _selectedDevice = _devices.firstWhere((d) => d.macAdress == _selectedDevice!.macAdress);
          }
        }
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
            leading: Icon(
              _isConnected
                  ? CupertinoIcons.printer_fill
                  : CupertinoIcons.printer,
              color: _isConnected ? Colors.green : scheme.primary,
            ),
            title: Text('Printer birikdir'),
            subtitle: Text(_isConnected ? 'Birikdirildi' : 'Birikdirilmedi'),
            trailing: IconButton(
              icon: Icon(CupertinoIcons.refresh),
              onPressed: _initPrinter,
            ),
          ),
          Column(
            children: [
              if (!_hasPermissions)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(CupertinoIcons.lock_shield, color: scheme.error, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Bluetooth rugsatlary berilmedik.',
                        style: TextStyle(color: scheme.error, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Printerleri görmek üçin rugsat gerek.',
                        style: TextStyle(color: scheme.outline, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () async {
                          await _printerService.requestPermissions();
                          await _initPrinter();
                        },
                        icon: Icon(CupertinoIcons.check_mark_circled, size: 16),
                        label: Text('Rugsat ber'),
                      ),
                    ],
                  ),
                )
              else if (_devices.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.bluetooth,
                        color: scheme.outline,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jübütlenen printer tapylmady.\nTelefonyň Bluetooth sazlamalaryndan ilki birikdiriň.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.outline, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _initPrinter,
                        icon: Icon(CupertinoIcons.refresh, size: 16),
                        label: Text('Tazele'),
                      ),
                    ],
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: DropdownButton<BluetoothInfo>(
                    isExpanded: true,
                    value: _selectedDevice,
                    hint: Text('Printer saýlaň'),
                    items: _devices.map((device) {
                      return DropdownMenuItem(
                        value: device,
                        child: Text(device.name),
                      );
                    }).toList(),
                    onChanged: (device) {
                      setState(() => _selectedDevice = device);
                    },
                  ),
                ),
            ],
          ),
          if (_selectedDevice != null && !_isConnected)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: FilledButton.icon(
                onPressed: () async {
                  if (_selectedDevice == null) return;
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await _printerService.connect(_selectedDevice!);
                    if (!mounted) return;
                    await _initPrinter();
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(content: Text('Baglanyşyk ýalňyşlygy: $e')),
                    );
                  }
                },
                icon: Icon(CupertinoIcons.link),
                label: Text('Birikdir'),
              ),
            ),
          if (_isConnected)
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await _printerService.disconnect();
                        await _initPrinter();
                      },
                      icon: Icon(CupertinoIcons.clear_circled, size: 18),
                      label: Text('Üz'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final message = await _printerService.printTest();
                        if (!mounted) return;
                        messenger.showSnackBar(SnackBar(content: Text(message)));
                      },
                      icon: Icon(CupertinoIcons.play_circle, size: 18),
                      label: Text('Synag çap'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Bildiriş sazlamalary kartasy ───────────────────────────
class _NotificationSettingsCard extends StatefulWidget {
  @override
  State<_NotificationSettingsCard> createState() =>
      _NotificationSettingsCardState();
}

class _NotificationSettingsCardState extends State<_NotificationSettingsCard> {
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

// ─── Dropdown saýlaýjy ──────────────────────────────────────
class _SettingsDropdown<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _SettingsDropdown({
    required this.icon,
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              alignment: AlignmentDirectional.centerEnd,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w600,
              ),
              icon: Icon(
                CupertinoIcons.chevron_down,
                size: 14,
                color: scheme.primary,
              ),
              selectedItemBuilder: (context) {
                return items.map((item) {
                  return Container(
                    alignment: Alignment.centerRight,
                    child: item.child,
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stol sazlamalary tile ───────────────────────────────────
class _TableSettingsTile extends StatelessWidget {
  final TableModel table;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TableSettingsTile({
    required this.table,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant.withAlpha(102)),
      ),
      child: Row(
        children: [
          // Ýagdaý indikatoru
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: table.isActive ? scheme.primary : scheme.outline,
              shape: BoxShape.circle,
            ),
          ),

          // Maglumat
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  table.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 15),
                ),
                Text(
                  '${table.pricePerHour.toStringAsFixed(1)} ${S.of(context).perHourShort}'
                  '${table.maxUsers != null ? "  ·  Max ${table.maxUsers}" : ""}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),

          // Düwmeler
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(CupertinoIcons.pencil),
                iconSize: 20,
                color: scheme.onSurfaceVariant,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(CupertinoIcons.trash),
                iconSize: 20,
                color: scheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
