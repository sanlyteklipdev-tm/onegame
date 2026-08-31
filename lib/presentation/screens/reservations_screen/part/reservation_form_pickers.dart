import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../data/models/employee_model.dart';
import '../../../providers/providers.dart';

/// Stol saýlaýjy
class ReservationTablePicker extends ConsumerWidget {
  final int? tableId;
  final ValueChanged<int?> onChanged;

  const ReservationTablePicker({
    super.key,
    required this.tableId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(tablesStreamProvider);
    final s = S.of(context);

    return tablesAsync.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (tables) => _PickerRow(
        icon: CupertinoIcons.table,
        child: DropdownButton<int>(
          isExpanded: true,
          value: tableId,
          underline: const SizedBox.shrink(),
          hint: Text(s.selectTable),
          items: tables
              .map((t) => DropdownMenuItem(value: t.id, child: Text(t.name)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Müşderi saýlaýjy (hökman däl)
class ReservationCustomerPicker extends ConsumerWidget {
  final int? customerId;
  final ValueChanged<CustomerModel?> onChanged;

  const ReservationCustomerPicker({
    super.key,
    required this.customerId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersStreamProvider);
    final s = S.of(context);

    return customersAsync.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (customers) {
        // Pozulan müşderä salgylanma galan bolsa dropdown ýykylmasyn
        final exists = customers.any((c) => c.id == customerId);
        return _PickerRow(
          icon: CupertinoIcons.person,
          child: DropdownButton<int>(
            isExpanded: true,
            value: exists ? customerId : null,
            underline: const SizedBox.shrink(),
            hint: Text(s.noCustomer),
            items: [
              DropdownMenuItem(value: null, child: Text(s.noCustomer)),
              ...customers.map(
                (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
              ),
            ],
            onChanged: (id) => onChanged(
              id == null ? null : customers.firstWhere((c) => c.id == id),
            ),
          ),
        );
      },
    );
  }
}

/// Jogapkär işgär saýlaýjy (hökman däl)
class ReservationEmployeePicker extends ConsumerWidget {
  final int? employeeId;
  final ValueChanged<int?> onChanged;

  const ReservationEmployeePicker({
    super.key,
    required this.employeeId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesStreamProvider);
    final s = S.of(context);

    return employeesAsync.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (all) {
        // Bronda diňe 2-nji görnüşdäki işgärler saýlanýar.
        // Direktor görnüşine garamazdan bronda görkezilmeýär.
        final employees = all
            .where(
              (e) =>
                  e.type == EmployeeType.type2 &&
                  e.position != EmployeePosition.director,
            )
            .toList();

        // Saýlanan işgär soň süzgüçden çykan bolsa dropdown ýykylmasyn
        final exists = employees.any((e) => e.id == employeeId);
        return _PickerRow(
          icon: CupertinoIcons.briefcase,
          child: DropdownButton<int>(
            isExpanded: true,
            value: exists ? employeeId : null,
            underline: const SizedBox.shrink(),
            hint: Text(employees.isEmpty ? s.noType2Employees : s.noEmployee),
            items: [
              DropdownMenuItem(value: null, child: Text(s.noEmployee)),
              ...employees.map(
                (e) => DropdownMenuItem(value: e.id, child: Text(e.name)),
              ),
            ],
            onChanged: onChanged,
          ),
        );
      },
    );
  }
}

/// Hyzmat saýlaýjy — bron üçin hökman
class ReservationServicePicker extends ConsumerWidget {
  final int? serviceId;
  final ValueChanged<int?> onChanged;

  const ReservationServicePicker({
    super.key,
    required this.serviceId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(servicesStreamProvider);
    final s = S.of(context);

    return servicesAsync.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (services) {
        // Pozulan hyzmata salgylanma galan bolsa dropdown ýykylmasyn
        final exists = services.any((x) => x.id == serviceId);
        return _PickerRow(
          icon: CupertinoIcons.sparkles,
          child: DropdownButton<int>(
            isExpanded: true,
            value: exists ? serviceId : null,
            underline: const SizedBox.shrink(),
            hint: Text(s.selectService),
            items: services
                .map(
                  (x) => DropdownMenuItem(
                    value: x.id,
                    child: Text(
                      '${x.name}  ·  ${AppFormatters.formatPrice(x.price, s.tmt)}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        );
      },
    );
  }
}

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final Widget child;

  const _PickerRow({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}
