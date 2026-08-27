import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/isar_service.dart';
import '../../../data/models/app_settings_model.dart';
import '../home_screen/home_screen.dart';
import 'part/license_form.dart';

class LicenseScreen extends ConsumerStatefulWidget {
  const LicenseScreen({super.key});

  @override
  ConsumerState<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends ConsumerState<LicenseScreen> {
  final TextEditingController _keyController = TextEditingController();
  bool _hasError = false;

  int get _systemCode {
    final now = DateTime.now();
    return (now.day * 100) + now.month + now.year;
  }

  int get _expectedKey => (_systemCode * 5) - 100;

  void _verifyKey() async {
    final input = int.tryParse(_keyController.text.trim());
    if (input == _expectedKey || input == 999999999) {
      // 999999999 = master aýratyn parol (isleg boýunça)
      final isar = IsarService.isar;
      await isar.writeTxn(() async {
        final settings = AppSettingsModel()..isLicensed = true;
        await isar.appSettingsModels.put(settings);
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LicenseForm(
          systemCode: _systemCode,
          keyController: _keyController,
          hasError: _hasError,
          onKeyChanged: () {
            if (_hasError) setState(() => _hasError = false);
          },
          onVerify: _verifyKey,
        ),
      ),
    );
  }
}
