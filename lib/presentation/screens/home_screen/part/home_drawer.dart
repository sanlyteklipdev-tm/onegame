import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/navigation_providers.dart';
import 'home_destinations.dart';

/// Süýşýän menýuny açmak üçin daşky Scaffold-a salgylanma.
///
/// Her ekranyň öz Scaffold-y bar we ol daşkyny gizleýär — şonuň üçin
/// menýu düwmesi `Scaffold.of(context)` bilen tapyp bilmeýär.
/// Programmada bir wagtda bir HomeScreen bolýar, şonuň üçin bir açar ýeterlik.
final homeScaffoldKey = GlobalKey<ScaffoldState>();

/// Telefonda aşaky menýunyň ýerine — ähli bölümler bir sanawda
class HomeDrawer extends ConsumerWidget {
  final List<HomeTab> tabs;

  const HomeDrawer({super.key, required this.tabs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = S.of(context);
    final selected = ref.watch(homeTabIndexProvider);
    final user = ref.watch(authProvider);
    final scheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.appTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (user != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${user.displayName} · ${s.roleLabel(user.role)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (var i = 0; i < tabs.length; i++)
                    _DrawerTile(
                      tab: tabs[i],
                      isSelected: i == selected,
                      onTap: () {
                        ref.read(homeTabIndexProvider.notifier).select(i);
                        Navigator.of(context).pop();
                      },
                      scheme: scheme,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final HomeTab tab;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme scheme;

  const _DrawerTile({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        selected: isSelected,
        selectedTileColor: scheme.secondaryContainer,
        selectedColor: scheme.onSecondaryContainer,
        leading: Icon(isSelected ? tab.selectedIcon : tab.icon),
        title: Text(
          tab.label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

/// Ekranlaryň başyndaky menýu düwmesi.
///
/// Diňe telefonda görkezilýär: planşetde we kompýuterde gapdaldaky
/// polosa bar, ol ýerde düwme artykmaç.
Widget? homeMenuLeading(BuildContext context) {
  if (MediaQuery.sizeOf(context).width >= 600) return null;
  return const HomeMenuButton();
}

class HomeMenuButton extends StatelessWidget {
  const HomeMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width >= 600) {
      return const SizedBox.shrink();
    }
    return IconButton(
      icon: const Icon(CupertinoIcons.line_horizontal_3),
      tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      onPressed: () => homeScaffoldKey.currentState?.openDrawer(),
    );
  }
}
