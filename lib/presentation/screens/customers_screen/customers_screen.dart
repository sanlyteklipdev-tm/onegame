import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/customer_model.dart';
import '../../providers/providers.dart';
import 'part/customer_form_sheet.dart';
import 'part/customer_tile.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final customersAsync = ref.watch(customersStreamProvider);
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
                  hintStyle: TextStyle(color: scheme.onSurfaceVariant.withAlpha(150)),
                ),
                style: const TextStyle(fontSize: 18),
                onChanged: (_) => setState(() {}),
              )
            : Text(s.customers),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? CupertinoIcons.xmark : CupertinoIcons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchCtrl.clear();
                }
                _isSearching = !_isSearching;
              });
            },
          ),
        ],
      ),
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${s.errorPrefix}: $e')),
        data: (customers) {
          final query = _searchCtrl.text.toLowerCase().trim();
          final filtered = customers.where((c) {
            return c.name.toLowerCase().contains(query);
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSearching ? CupertinoIcons.search : CupertinoIcons.person_2,
                    size: 64,
                    color: scheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching ? s.noResults : s.noCustomers,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSearching ? s.tryDifferentSearch : s.noCustomersHint,
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
            itemBuilder: (context, i) {
              final c = filtered[i];
              return CustomerTile(customer: c);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context, ref, null),
        icon: const Icon(CupertinoIcons.person_add),
        label: Text(S.of(context).addCustomer),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, WidgetRef ref, CustomerModel? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CustomerFormSheet(existing: existing),
    );
  }
}
