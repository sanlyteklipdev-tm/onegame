import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';

class TableSearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool hasQuery;
  const TableSearchField({
    super.key,
    required this.controller,
    required this.hasQuery,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: s.searchTableHint,
          prefixIcon: const Icon(CupertinoIcons.search, size: 20),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: const Icon(
                    CupertinoIcons.clear_circled_solid,
                    size: 18,
                  ),
                  onPressed: controller.clear,
                )
              : null,
          filled: true,
          fillColor: scheme.surfaceContainerHighest.withAlpha(153),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: scheme.outlineVariant.withAlpha(102),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
