import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/activation_api_service.dart';
import '../../providers/providers.dart';
import '../device_registration_screen/device_registration_screen.dart';
import 'part/login_form.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorText = 'Ähli meýdanlary dolduryň');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final api = ref.read(activationApiServiceProvider);
    try {
      final token = await api.login(username: username, password: password);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DeviceRegistrationScreen(token: token),
        ),
      );
    } on WrongCredentialsException {
      setState(() => _errorText = 'Ulanyjy ady ýa-da parol nädogry');
    } on ApiRequestException catch (e) {
      setState(() => _errorText = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LoginForm(
          usernameController: _usernameController,
          passwordController: _passwordController,
          isLoading: _isLoading,
          errorText: _errorText,
          onSubmit: _login,
        ),
      ),
    );
  }
}
