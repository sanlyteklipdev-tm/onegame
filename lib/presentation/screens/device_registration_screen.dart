import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/activation_api_service.dart';
import '../../core/services/device_id_service.dart';
import '../providers/providers.dart';
import 'waiting_activation_screen.dart';

class DeviceRegistrationScreen extends ConsumerStatefulWidget {
  final String token;
  const DeviceRegistrationScreen({super.key, required this.token});

  @override
  ConsumerState<DeviceRegistrationScreen> createState() =>
      _DeviceRegistrationScreenState();
}

class _DeviceRegistrationScreenState
    extends ConsumerState<DeviceRegistrationScreen> {
  final _shopNameController = TextEditingController();
  final _descriptionMainController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  Future<void> _submit() async {
    final shopName = _shopNameController.text.trim();
    final descriptionMain = _descriptionMainController.text.trim();
    final description = _descriptionController.text.trim();

    if (shopName.isEmpty || descriptionMain.isEmpty || description.isEmpty) {
      setState(() => _errorText = 'Ähli meýdanlary dolduryň');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final api = ref.read(activationApiServiceProvider);
    try {
      final deviceImei = await DeviceIdService.getDeviceId();
      await api.registerDevice(
        token: widget.token,
        deviceImei: deviceImei,
        shopName: shopName,
        descriptionMain: descriptionMain,
        description: description,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WaitingActivationScreen()),
      );
    } on ApiRequestException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _descriptionMainController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
              const SizedBox(height: 40),
              Icon(CupertinoIcons.bag_fill, size: 72, color: scheme.primary),
              const SizedBox(height: 24),
              Text(
                'Enjamy hasaba almak',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Dükan barada maglumat giriziň, soň dolandyryjynyň tassyklamagyny garaşarsyňyz.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _shopNameController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Dükanyň ady',
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionMainController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Esasy düşündiriş',
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Düşündiriş',
                  errorText: _errorText,
                  filled: true,
                  fillColor: scheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'IBERMEK',
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
