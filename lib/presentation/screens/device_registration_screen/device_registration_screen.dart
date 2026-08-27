import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/activation_api_service.dart';
import '../../../core/services/device_id_service.dart';
import '../../providers/providers.dart';
import '../waiting_activation_screen/waiting_activation_screen.dart';
import 'part/registration_form.dart';

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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: RegistrationForm(
          shopNameController: _shopNameController,
          descriptionMainController: _descriptionMainController,
          descriptionController: _descriptionController,
          isLoading: _isLoading,
          errorText: _errorText,
          onSubmit: _submit,
        ),
      ),
    );
  }
}
