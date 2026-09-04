import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../data/models/customer_model.dart';
import '../../providers/providers.dart';
import 'part/customer_form_sheet.dart';
import '../../widgets/entity_card.dart';
import '../../widgets/entity_grid.dart';
import '../home_screen/part/home_drawer.dart';

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

  void _confirmDelete(CustomerModel item) {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteCustomer),
        content: Text(s.deleteCustomerConfirm(item.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            onPressed: () {
              ref
                  .read(customerNotifierProvider.notifier)
                  .deleteCustomer(item.id);
              Navigator.pop(ctx);
            },
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final customersAsync = ref.watch(customersStreamProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: homeMenuLeading(context),
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
            : Text(s.customers),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? CupertinoIcons.xmark : CupertinoIcons.search,
            ),
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
                    _isSearching
                        ? CupertinoIcons.search
                        : CupertinoIcons.person_2,
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

          return EntityGrid(
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final c = filtered[i];
              return EntityCard(
                name: c.name,
                icon: CupertinoIcons.person,
                badge: c.category.label,
                subtitle: c.discountPercentage > 0
                    ? '${s.discount}: ${c.discountPercentage.toStringAsFixed(0)}%'
                    : (c.phone ?? s.noDiscount),
                deviceName: c.deviceName,
                onEdit: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => CustomerFormSheet(existing: c),
                ),
                onDelete: () => _confirmDelete(c),
              );
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

  void _showAddEditDialog(
    BuildContext context,
    WidgetRef ref,
    CustomerModel? existing,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CustomerFormSheet(existing: existing),
    );
  }
}
