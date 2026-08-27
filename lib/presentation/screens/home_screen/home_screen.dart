import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../tables_screen/tables_screen.dart';
import '../reports_screen/reports_screen.dart';
import '../reservations_screen/reservations_screen.dart';
import '../settings_screen/settings_screen.dart';
import '../customers_screen/customers_screen.dart';
import '../employees_screen/employees_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TablesScreen(),
    const ReservationsScreen(),
    const CustomersScreen(),
    const EmployeesScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= 600;

    final destinations = [
      NavigationDestination(
        icon: const Icon(CupertinoIcons.house),
        selectedIcon: const Icon(CupertinoIcons.house_fill),
        label: s.tables,
      ),
      NavigationDestination(
        icon: const Icon(CupertinoIcons.calendar),
        selectedIcon: const Icon(CupertinoIcons.calendar_today),
        label: s.reservations,
      ),
      NavigationDestination(
        icon: const Icon(CupertinoIcons.person_2),
        selectedIcon: const Icon(CupertinoIcons.person_2_fill),
        label: s.customers,
      ),
      NavigationDestination(
        icon: const Icon(CupertinoIcons.briefcase),
        selectedIcon: const Icon(CupertinoIcons.briefcase_fill),
        label: s.employees,
      ),
      NavigationDestination(
        icon: const Icon(CupertinoIcons.graph_square),
        selectedIcon: const Icon(CupertinoIcons.graph_square_fill),
        label: s.reports,
      ),
      NavigationDestination(
        icon: const Icon(CupertinoIcons.settings),
        selectedIcon: const Icon(CupertinoIcons.settings_solid),
        label: s.settings,
      ),
    ];

    final railDestinations = [
      NavigationRailDestination(
        icon: const Icon(CupertinoIcons.house),
        selectedIcon: const Icon(CupertinoIcons.house_fill),
        label: Text(s.tables),
      ),
      NavigationRailDestination(
        icon: const Icon(CupertinoIcons.calendar),
        selectedIcon: const Icon(CupertinoIcons.calendar_today),
        label: Text(s.reservations),
      ),
      NavigationRailDestination(
        icon: const Icon(CupertinoIcons.person_2),
        selectedIcon: const Icon(CupertinoIcons.person_2_fill),
        label: Text(s.customers),
      ),
      NavigationRailDestination(
        icon: const Icon(CupertinoIcons.briefcase),
        selectedIcon: const Icon(CupertinoIcons.briefcase_fill),
        label: Text(s.employees),
      ),
      NavigationRailDestination(
        icon: const Icon(CupertinoIcons.graph_square),
        selectedIcon: const Icon(CupertinoIcons.graph_square_fill),
        label: Text(s.reports),
      ),
      NavigationRailDestination(
        icon: const Icon(CupertinoIcons.settings),
        selectedIcon: const Icon(CupertinoIcons.settings_solid),
        label: Text(s.settings),
      ),
    ];

    if (isTablet) {
      // ── Planşet ─────────────── NavigationRail + Screen
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              labelType: width >= 800
                  ? NavigationRailLabelType.all
                  : NavigationRailLabelType.selected,
              destinations: railDestinations,
              leading: const SizedBox(height: 16),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      );
    }

    // ── Telefon ─────────────── BottomNavigationBar
    return Scaffold(
      body: _screens[_selectedIndex],
      // Ulgamyň şrift ulaltmasy 6 bölümiň ýazgysyny kesmez ýaly çäklendirilýär
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.0,
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: destinations,
        ),
      ),
    );
  }
}
