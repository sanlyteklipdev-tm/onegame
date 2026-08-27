import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../providers/providers.dart';
import 'activation_check_tile.dart';
import 'settings_dropdown.dart';

// ─── Daşky görnüş (Tema we Dil) kartasy ────────────────────
class AppearanceCard extends ConsumerWidget {
  const AppearanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    final currentTheme = ref.watch(themeModeProvider);
    final currentLang = ref.watch(appLanguageProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withAlpha(102)),
      ),
      child: Column(
        children: [
          // Tema saýlaýjy
          SettingsDropdown<ThemeMode>(
            icon: CupertinoIcons.moon_stars,
            title: s.theme,
            value: currentTheme,
            items: [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text(s.themeSystem),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text(s.themeLight),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text(s.themeDark),
              ),
            ],
            onChanged: (v) {
              if (v != null) {
                ref.read(themeModeProvider.notifier).setTheme(v);
              }
            },
          ),
          Divider(height: 1, color: scheme.outlineVariant.withAlpha(77)),
          // Dil saýlaýjy
          SettingsDropdown<AppLanguage>(
            icon: CupertinoIcons.globe,
            title: s.language,
            value: currentLang,
            items: AppLanguage.values.map((lang) {
              return DropdownMenuItem(
                value: lang,
                child: Text(lang.displayName, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                ref.read(appLanguageProvider.notifier).setLanguage(v);
              }
            },
          ),
          Divider(height: 1, color: scheme.outlineVariant.withAlpha(77)),
          const ActivationCheckTile(),
        ],
      ),
    );
  }
}
