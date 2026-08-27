import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../providers/providers.dart';
import 'part/employee_form_sheet.dart';
import 'part/employee_tile.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const EmployeeFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final employeesAsync = ref.watch(employeesStreamProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: s.search,
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: scheme.onSurfaceVariant.withAlpha(150),
                  ),
                ),
                style: const TextStyle(fontSize: 18),
                onChanged: (_) => setState(() {}),
              )
            : Text(s.employees),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? CupertinoIcons.xmark : CupertinoIcons.search,
            ),
            onPressed: () {
              setState(() {
                if (_isSearching) _searchCtrl.clear();
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: employeesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${s.errorPrefix}: $e')),
        data: (employees) {
          final query = _searchCtrl.text.toLowerCase().trim();
          final filtered = employees
              .where((e) => e.name.toLowerCase().contains(query))
              .toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSearching
                        ? CupertinoIcons.search
                        : CupertinoIcons.person_2,
                    size: 64,
                    color: scheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching ? s.noResults : s.noEmployees,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSearching ? s.tryDifferentSearch : s.noEmployeesHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 8),
            itemBuilder: (context, i) => EmployeeTile(employee: filtered[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'employee-add',
        onPressed: _showForm,
        icon: const Icon(CupertinoIcons.person_add),
        label: Text(s.addEmployee),
      ),
    );
  }
}
