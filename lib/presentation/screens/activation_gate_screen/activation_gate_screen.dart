import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/activation_api_service.dart';
import '../../../core/services/activation_cache_service.dart';
import '../../providers/providers.dart';
import '../home_screen/home_screen.dart';
import '../login_screen/login_screen.dart';
import '../waiting_activation_screen/waiting_activation_screen.dart';

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
      final status = await checkAndCacheActivation(api);
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
    } on NoInternetException {
      // Internet ýok — soňky ýatda saklanan is_active ýagdaýyna görä giriş ber.
      final cached = await ActivationCacheService.getCachedIsActive();
      if (!mounted) return;
      if (cached != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) =>
                cached ? const HomeScreen() : const WaitingActivationScreen(),
          ),
        );
      } else {
        setState(() => _errorText = S.of(context).noInternetFirstCheck);
      }
    } on ApiRequestException catch (e) {
      setState(() => _errorText = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

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
                      child: Text(s.retry),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
