import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PrinterHeaderTile extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onRefresh;

  const PrinterHeaderTile({
    super.key,
    required this.isConnected,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        isConnected ? CupertinoIcons.printer_fill : CupertinoIcons.printer,
        color: isConnected ? Colors.green : scheme.primary,
      ),
      title: const Text('Printer birikdir'),
      subtitle: Text(isConnected ? 'Birikdirildi' : 'Birikdirilmedi'),
      trailing: IconButton(
        icon: const Icon(CupertinoIcons.refresh),
        onPressed: onRefresh,
      ),
    );
  }
}
