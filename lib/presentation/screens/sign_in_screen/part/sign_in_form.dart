import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';

/// Giriş formasy — ady, paroly we düwme.
/// Ýalňyşlyk habaryny daşyndan alýar.
class SignInForm extends StatefulWidget {
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final bool isLoading;
  final String? errorText;
  final VoidCallback onSubmit;

  const SignInForm({
    super.key,
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.isLoading,
    required this.errorText,
    required this.onSubmit,
  });

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.usernameCtrl,
          autofocus: true,
          enabled: !widget.isLoading,
          textInputAction: TextInputAction.next,
          autocorrect: false,
          // Klawiatura ilkinji harpy uly etmesin
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            labelText: s.username,
            prefixIcon: const Icon(CupertinoIcons.person, size: 18),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: widget.passwordCtrl,
          enabled: !widget.isLoading,
          obscureText: _obscure,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => widget.onSubmit(),
          decoration: InputDecoration(
            labelText: s.password,
            prefixIcon: const Icon(CupertinoIcons.lock, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? CupertinoIcons.eye : CupertinoIcons.eye_slash,
                size: 18,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),

        if (widget.errorText != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.errorText!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.error),
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: 24),

        FilledButton(
          onPressed: widget.isLoading ? null : widget.onSubmit,
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(s.signIn),
        ),
      ],
    );
  }
}
