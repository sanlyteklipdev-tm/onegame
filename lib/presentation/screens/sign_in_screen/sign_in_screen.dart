import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/auth_service.dart';
import '../../providers/auth_providers.dart';
import '../home_screen/home_screen.dart';
import 'part/sign_in_form.dart';

/// Ulanyjynyň girişi. Bu ýerdäki at we parol bazanyň öz hasaby —
/// hukuklary baza barlaýar, programma däl.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Näbelli ýalňyşlykda "parol nädogry" diýmek nädogry bolar —
  /// hakyky sebäbi gizlemeli däl, ýogsam näme bolýanyny tapyp bolmaýar.
  String _messageFor(AuthException e, S s) => switch (e.failure) {
    AuthFailure.badCredentials => s.errWrongCredentials,
    AuthFailure.unreachable => s.errDbUnreachable,
    AuthFailure.noRole => s.errNoRole,
    AuthFailure.unknown => '${s.errorPrefix}: ${e.details}',
  };

  Future<void> _submit() async {
    final s = S.of(context);
    final navigator = Navigator.of(context);

    final username = _usernameCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (username.isEmpty) {
      setState(() => _errorText = s.enterUsername);
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorText = s.enterPassword);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .signIn(username: username, password: password);
      if (!mounted) return;
      navigator.pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorText = _messageFor(e, s));
    } catch (e) {
      if (mounted) setState(() => _errorText = '${s.errorPrefix}: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),

                  const SizedBox(height: 24),

                  Text(s.signInTitle, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    s.signInSubtitle,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  SignInForm(
                    usernameCtrl: _usernameCtrl,
                    passwordCtrl: _passwordCtrl,
                    isLoading: _isLoading,
                    errorText: _errorText,
                    onSubmit: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
