import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LicenseForm extends StatelessWidget {
  final int systemCode;
  final TextEditingController keyController;
  final bool hasError;
  final VoidCallback onKeyChanged;
  final VoidCallback onVerify;

  const LicenseForm({
    super.key,
    required this.systemCode,
    required this.keyController,
    required this.hasError,
    required this.onKeyChanged,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
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

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant.withAlpha(128)),
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
                  '$systemCode',
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

          TextField(
            controller: keyController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              labelText: 'Aktiwasiýa açary',
              hintText: 'XXXXX',
              errorText: hasError ? 'Açar nädogry! Täzeden synanşyň.' : null,
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
            onChanged: (_) => onKeyChanged(),
          ),
          const SizedBox(height: 32),

          FilledButton(
            onPressed: onVerify,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text(
              'TASSYKLA WE AÇ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }
}
