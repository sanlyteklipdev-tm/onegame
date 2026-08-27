import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../core/services/printer_service.dart';

class PrinterDeviceSection extends StatelessWidget {
  final bool hasPermissions;
  final List<BluetoothInfo> devices;
  final BluetoothInfo? selectedDevice;
  final PrinterService printerService;
  final VoidCallback onRefresh;
  final ValueChanged<BluetoothInfo?> onDeviceSelected;

  const PrinterDeviceSection({
    super.key,
    required this.hasPermissions,
    required this.devices,
    required this.selectedDevice,
    required this.printerService,
    required this.onRefresh,
    required this.onDeviceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (!hasPermissions) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(CupertinoIcons.lock_shield, color: scheme.error, size: 32),
            const SizedBox(height: 8),
            Text(
              'Bluetooth rugsatlary berilmedik.',
              style: TextStyle(
                color: scheme.error,
                fontWeight: FontWeight.bold,
              ),
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
                await printerService.requestPermissions();
                onRefresh();
              },
              icon: const Icon(CupertinoIcons.check_mark_circled, size: 16),
              label: const Text('Rugsat ber'),
            ),
          ],
        ),
      );
    }

    if (devices.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(CupertinoIcons.bluetooth, color: scheme.outline, size: 32),
            const SizedBox(height: 8),
            Text(
              'Jübütlenen printer tapylmady.\nTelefonyň Bluetooth sazlamalaryndan ilki birikdiriň.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.outline, fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(CupertinoIcons.refresh, size: 16),
              label: const Text('Tazele'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButton<BluetoothInfo>(
        isExpanded: true,
        value: selectedDevice,
        hint: const Text('Printer saýlaň'),
        items: devices.map((device) {
          return DropdownMenuItem(value: device, child: Text(device.name));
        }).toList(),
        onChanged: onDeviceSelected,
      ),
    );
  }
}
