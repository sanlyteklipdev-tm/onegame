import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/activation_api_service.dart';
import '../../core/services/device_id_service.dart';
import '../providers/providers.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'waiting_activation_screen.dart';

class ActivationGateScreen extends ConsumerStatefulWidget {
  const ActivationGateScreen({super.key});

  @override
  ConsumerState<ActivationGateScreen> createState() =>
      _ActivationGateScreenState();
}

class _ActivationGateScreenState extends ConsumerState<ActivationGateScreen> {
  String? _errorText;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    setState(() => _errorText = null);

    final api = ref.read(activationApiServiceProvider);
    try {
      final deviceImei = await DeviceIdService.getDeviceId();
      final status = await api.checkDeviceStatus(deviceImei);
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => status == DeviceActivationStatus.active
              ? const HomeScreen()
              : const WaitingActivationScreen(),
        ),
      );
    } on DeviceNotRegisteredException {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on ApiRequestException catch (e) {
      setState(() => _errorText = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: _errorText == null
            ? CircularProgressIndicator(color: scheme.primary)
            : Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _errorText!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _checkStatus,
                      child: const Text('GAÝTADAN SYNANYŞMAK'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
