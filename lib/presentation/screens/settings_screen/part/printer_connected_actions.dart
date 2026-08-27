import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/printer_service.dart';

class PrinterConnectedActions extends StatelessWidget {
  final PrinterService printerService;
  final VoidCallback onDisconnected;

  const PrinterConnectedActions({
    super.key,
    required this.printerService,
    required this.onDisconnected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                await printerService.disconnect();
                onDisconnected();
              },
              icon: const Icon(CupertinoIcons.clear_circled, size: 18),
              label: const Text('Üz'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: FilledButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final message = await printerService.printTest();
                if (!context.mounted) return;
                messenger.showSnackBar(SnackBar(content: Text(message)));
              },
              icon: const Icon(CupertinoIcons.play_circle, size: 18),
              label: const Text('Synag çap'),
            ),
          ),
        ],
      ),
    );
  }
}
