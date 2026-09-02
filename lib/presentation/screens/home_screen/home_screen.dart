import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/data_source.dart';
import '../../providers/auth_providers.dart';
import '../worker_screen/worker_screen.dart';
import 'part/home_destinations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final role = ref.watch(currentRoleProvider);

    // Isar rejiminde giriş ýok — hemme zat elýeterli
    final effectiveRole = DataSourceConfig.usePostgres
        ? role
        : AppRole.admin;

    // Giriş entek gutarmadyk bolsa garaşylýar
    if (effectiveRole == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Işgäriň öz ekrany — menýusyz
    if (effectiveRole.isWorker) return const WorkerScreen();

    final tabs = buildHomeTabs(s, effectiveRole);

    // Rol çalşanda saýlanan bölüm sanawdan çykmaz ýaly
    final index = _selectedIndex.clamp(0, tabs.length - 1);

    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;

    if (isTablet) {
      // ── Planşet ─────────────── NavigationRail + Screen
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: (i) =>
                  setState(() => _selectedIndex = i),
              labelType: width >= 800
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.selected,
              destinations: [
                for (final t in tabs)
                  NavigationRailDestination(
                    icon: Icon(t.icon),
                    selectedIcon: Icon(t.selectedIcon),
                    label: Text(t.label),
                  ),
              ],
              leading: const SizedBox(height: 16),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: tabs[index].screen),
          ],
        ),
      );
    }

    // ── Telefon ─────────────── BottomNavigationBar
    return Scaffold(
      body: tabs[index].screen,
      // Ulgamyň şrift ulaltmasy bölümleriň ýazgysyny kesmez ýaly çäklendirilýär
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.0,
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          destinations: [
            for (final t in tabs)
              NavigationDestination(
                icon: Icon(t.icon),
                selectedIcon: Icon(t.selectedIcon),
                label: t.label,
              ),
          ],
        ),
      ),
    );
  }
}
