import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../core/services/printer_service.dart';

class PrinterConnectButton extends StatelessWidget {
  final BluetoothInfo selectedDevice;
  final PrinterService printerService;
  final VoidCallback onConnected;

  const PrinterConnectButton({
    super.key,
    required this.selectedDevice,
    required this.printerService,
    required this.onConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FilledButton.icon(
        onPressed: () async {
          final messenger = ScaffoldMessenger.of(context);
          try {
            await printerService.connect(selectedDevice);
            if (!context.mounted) return;
            onConnected();
          } catch (e) {
            if (!context.mounted) return;
            messenger.showSnackBar(
              SnackBar(content: Text('Baglanyşyk ýalňyşlygy: $e')),
            );
          }
        },
        icon: const Icon(CupertinoIcons.link),
        label: const Text('Birikdir'),
      ),
    );
  }
}
