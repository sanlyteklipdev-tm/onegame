import 'package:flutter/material.dart';

class QuickFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const QuickFilterChip({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      side: BorderSide(
        color: Theme.of(context).colorScheme.outline.withAlpha(77),
      ),
    );
  }
}
