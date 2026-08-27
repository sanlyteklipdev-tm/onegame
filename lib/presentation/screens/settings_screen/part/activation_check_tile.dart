import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/activation_api_service.dart';
import '../../../../core/services/activation_cache_service.dart';
import '../../../providers/providers.dart';
import '../../login_screen/login_screen.dart';
import '../../waiting_activation_screen/waiting_activation_screen.dart';

// ─── Aktiwlik barlagy düwmesi ───────────────────────────────
class ActivationCheckTile extends ConsumerStatefulWidget {
  const ActivationCheckTile({super.key});

  @override
  ConsumerState<ActivationCheckTile> createState() =>
      _ActivationCheckTileState();
}

class _ActivationCheckTileState extends ConsumerState<ActivationCheckTile> {
  bool _isChecking = false;

  Future<void> _check() async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context, rootNavigator: true);
    final errorColor = Theme.of(context).colorScheme.error;

    setState(() => _isChecking = true);
    final api = ref.read(activationApiServiceProvider);
    try {
      final status = await checkAndCacheActivation(api);
      if (!mounted) return;

      if (status == DeviceActivationStatus.active) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(s.deviceActiveMessage),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WaitingActivationScreen()),
          (route) => false,
        );
      }
    } on DeviceNotRegisteredException {
      if (!mounted) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } on NoInternetException {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(s.noInternetConnection),
          backgroundColor: errorColor,
        ),
      );
    } on ApiRequestException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: errorColor),
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.checkmark_shield,
            size: 20,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              s.activationCheckTitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 9,
              ),
            ),
            onPressed: _isChecking ? null : _check,
            child: _isChecking
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(s.checkActivation, style: TextStyle(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}
