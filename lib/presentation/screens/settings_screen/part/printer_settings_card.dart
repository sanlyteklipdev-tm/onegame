import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../core/services/printer_service.dart';
import 'printer_connect_button.dart';
import 'printer_connected_actions.dart';
import 'printer_device_section.dart';
import 'printer_header_tile.dart';

// ─── Printer sazlamalary kartasy ───────────────────────────
class PrinterSettingsCard extends StatefulWidget {
  const PrinterSettingsCard({super.key});

  @override
  State<PrinterSettingsCard> createState() => _PrinterSettingsCardState();
}

class _PrinterSettingsCardState extends State<PrinterSettingsCard> {
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
          final exists = _devices.any(
            (d) => d.macAdress == _selectedDevice!.macAdress,
          );
          if (!exists) {
            _selectedDevice = null;
          } else {
            // Update reference to the new instance from the list to avoid object mismatch
            _selectedDevice = _devices.firstWhere(
              (d) => d.macAdress == _selectedDevice!.macAdress,
            );
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
          PrinterHeaderTile(
            isConnected: _isConnected,
            onRefresh: _initPrinter,
          ),
          PrinterDeviceSection(
            hasPermissions: _hasPermissions,
            devices: _devices,
            selectedDevice: _selectedDevice,
            printerService: _printerService,
            onRefresh: _initPrinter,
            onDeviceSelected: (d) => setState(() => _selectedDevice = d),
          ),
          if (_selectedDevice != null && !_isConnected)
            PrinterConnectButton(
              selectedDevice: _selectedDevice!,
              printerService: _printerService,
              onConnected: _initPrinter,
            ),
          if (_isConnected)
            PrinterConnectedActions(
              printerService: _printerService,
              onDisconnected: _initPrinter,
            ),
        ],
      ),
    );
  }
}
