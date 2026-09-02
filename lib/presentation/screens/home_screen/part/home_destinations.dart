import 'package:flutter/cupertino.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/services/auth_service.dart';
import '../../customers_screen/customers_screen.dart';
import '../../employees_screen/employees_screen.dart';
import '../../reports_screen/reports_screen.dart';
import '../../reservations_screen/reservations_screen.dart';
import '../../services_screen/services_screen.dart';
import '../../settings_screen/settings_screen.dart';
import '../../tables_screen/tables_screen.dart';

/// Menýunyň bir bölümi
class HomeTab {
  final Widget screen;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const HomeTab({
    required this.screen,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Rola görä menýu düzülýär.
///
/// Bu diňe görnüş — hakyky çäklendirme bazada. Menejer hasabatlary
/// görüp bilýär, sebäbi bazada rugsat bar; işgär welin görüp
/// bilmeýär, sebäbi bazada rugsat ýok.
///
/// Işgär (worker) bu ýere düşmeýär — onuň öz aýratyn ekrany bar.
List<HomeTab> buildHomeTabs(S s, AppRole role) {
  final isAdmin = role == AppRole.admin;

  return [
    HomeTab(
      screen: const TablesScreen(),
      icon: CupertinoIcons.house,
      selectedIcon: CupertinoIcons.house_fill,
      label: s.tables,
    ),
    HomeTab(
      screen: const ReservationsScreen(),
      icon: CupertinoIcons.calendar,
      selectedIcon: CupertinoIcons.calendar_today,
      label: s.reservations,
    ),
    HomeTab(
      screen: const CustomersScreen(),
      icon: CupertinoIcons.person_2,
      selectedIcon: CupertinoIcons.person_2_fill,
      label: s.customers,
    ),
    // Işgärleri diňe administrator dolandyryp bilýär
    if (isAdmin)
      HomeTab(
        screen: const EmployeesScreen(),
        icon: CupertinoIcons.briefcase,
        selectedIcon: CupertinoIcons.briefcase_fill,
        label: s.employees,
      ),
    HomeTab(
      screen: const ServicesScreen(),
      icon: CupertinoIcons.sparkles,
      selectedIcon: CupertinoIcons.sparkles,
      label: s.services,
    ),
    HomeTab(
      screen: const ReportsScreen(),
      icon: CupertinoIcons.graph_square,
      selectedIcon: CupertinoIcons.graph_square_fill,
      label: s.reports,
    ),
    // Sazlamalar hemmä galýar: dil, tema we enjamyň ady — her
    // enjamyň öz sazlamasy. Işgärleri dolandyrmak welin ýokarda ýapyk.
    HomeTab(
      screen: const SettingsScreen(),
      icon: CupertinoIcons.settings,
      selectedIcon: CupertinoIcons.settings_solid,
      label: s.settings,
    ),
  ];
}
