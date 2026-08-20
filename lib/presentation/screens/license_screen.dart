import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/isar_service.dart';
import '../../data/models/app_settings_model.dart';
import 'home_screen.dart';

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

  int get _expectedKey {
    return (_systemCode * 5) - 100;
  }

  void _verifyKey() async {
    final input = int.tryParse(_keyController.text.trim());
    if (input == _expectedKey || input == 999999999) { // 999999999 = master aýratyn parol (isleg boýunça)
      // Litsenziýa dogry
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
      // Nädogry açar
      setState(() => _hasError = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Icon(CupertinoIcons.lock_shield_fill, size: 80, color: scheme.primary),
              const SizedBox(height: 24),
              Text(
                'Ulgamy işjeňleşdiriň',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Programmany ulanmak üçin aktiwasiýa açaryny giriziň. Açary almak üçin dolandyryja ýüz tutuň.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Ulgam Kody
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: scheme.outlineVariant.withAlpha(128)), // 0.5 * 255
                ),
                child: Column(
                  children: [
                    Text(
                      'Ulgam Kody:',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_systemCode',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: scheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Açary girizmek
              TextField(
                controller: _keyController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  labelText: 'Aktiwasiýa açary',
                  hintText: 'XXXXX',
                  errorText: _hasError ? 'Açar nädogry! Täzeden synanşyň.' : null,
                  filled: true,
                  fillColor: scheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: scheme.primary, width: 2),
                  ),
                ),
                onChanged: (v) {
                  if (_hasError) setState(() => _hasError = false);
                },
              ),
              const SizedBox(height: 32),

              FilledButton(
                onPressed: _verifyKey,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('TASSYKLA WE AÇ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
