import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Aşakdan açylýan formalaryň umumy «ýatda sakla» düwmesi
class SheetSubmitButton extends StatelessWidget {
  final bool isLoading;
  final bool isEdit;
  final String label;
  final VoidCallback onPressed;

  const SheetSubmitButton({
    super.key,
    required this.isLoading,
    required this.isEdit,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                isEdit ? CupertinoIcons.checkmark : CupertinoIcons.person_add,
              ),
        label: Text(label),
      ),
    );
  }
}
