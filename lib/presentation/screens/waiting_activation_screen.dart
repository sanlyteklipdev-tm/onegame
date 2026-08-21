import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/activation_api_service.dart';
import '../../core/services/device_id_service.dart';
import '../providers/providers.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class WaitingActivationScreen extends ConsumerStatefulWidget {
  const WaitingActivationScreen({super.key});

  @override
  ConsumerState<WaitingActivationScreen> createState() =>
      _WaitingActivationScreenState();
}

class _WaitingActivationScreenState
    extends ConsumerState<WaitingActivationScreen> {
  bool _isChecking = false;
  String? _errorText;

  Future<void> _checkStatus() async {
    setState(() {
      _isChecking = true;
      _errorText = null;
    });

    final api = ref.read(activationApiServiceProvider);
    try {
      final deviceImei = await DeviceIdService.getDeviceId();
      final status = await api.checkDeviceStatus(deviceImei);
      if (!mounted) return;

      if (status == DeviceActivationStatus.active) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        setState(() => _errorText = 'Enjam heniz tassyklanmady. Garaşyň.');
      }
    } on DeviceNotRegisteredException {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on ApiRequestException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(CupertinoIcons.time, size: 80, color: scheme.primary),
              const SizedBox(height: 24),
              Text(
                'Tassyklama garaşylýar',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Dolandyryjy enjamyňyzy tassyklanda, aşakdaky düwmä basyp barlaň.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 20),
                Text(
                  _errorText!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isChecking ? null : _checkStatus,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isChecking
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'BARLAMAK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
