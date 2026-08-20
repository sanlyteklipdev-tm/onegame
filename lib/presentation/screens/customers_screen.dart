import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../data/models/customer_model.dart';
import '../providers/providers.dart';

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
              return _CustomerTile(customer: c);
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
      builder: (_) => _CustomerFormSheet(existing: existing),
    );
  }
}

class _CustomerTile extends ConsumerWidget {
  final CustomerModel customer;
  const _CustomerTile({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Text(
            customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
            style: TextStyle(color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: customer.discountPercentage > 0
            ? Row(
                children: [
                  Icon(CupertinoIcons.tag, size: 13, color: Colors.green.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${s.discount}: ${customer.discountPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500), 
                  ),
                ],
              )
            : Text(s.noDiscount, style: TextStyle(color: scheme.onSurfaceVariant)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.pencil, size: 18),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => _CustomerFormSheet(existing: customer),
              ),
            ),
            IconButton(
              icon: Icon(CupertinoIcons.delete, size: 18, color: scheme.error),
              onPressed: () => _confirmDelete(context, ref, s),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, S s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteCustomer),
        content: Text(s.deleteCustomerConfirm(customer.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              ref.read(customerNotifierProvider.notifier).deleteCustomer(customer.id);
              Navigator.pop(ctx);
            },
            child: Text(s.delete),
          ),
        ],
      ),
    );
  }
}

class _CustomerFormSheet extends ConsumerStatefulWidget {
  final CustomerModel? existing;
  const _CustomerFormSheet({this.existing});

  @override
  ConsumerState<_CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends ConsumerState<_CustomerFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _discountCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _discountCtrl = TextEditingController(
        text: widget.existing?.discountPercentage.toStringAsFixed(0) ?? '0');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = S.of(context);
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final discount = double.tryParse(_discountCtrl.text.trim()) ?? 0.0;

    setState(() => _isLoading = true);
    try {
      final customer = widget.existing ?? CustomerModel();
      customer.name = name;
      customer.discountPercentage = discount.clamp(0, 100);
      if (widget.existing == null) {
        customer.createdAt = DateTime.now();
      }
      await ref.read(customerNotifierProvider.notifier).saveCustomer(customer);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${s.errorPrefix}: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset + 24 : 24,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isEdit ? s.editCustomer : s.addCustomer,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 24),

          Text(s.customerName, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: s.customerNameHint,
              prefixIcon: const Icon(CupertinoIcons.person, size: 18),
            ),
          ),

          const SizedBox(height: 16),

          Text(s.discountPercent, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _discountCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: '%',
              prefixIcon: const Icon(CupertinoIcons.tag, size: 18),
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(isEdit ? CupertinoIcons.checkmark : CupertinoIcons.person_add),
              label: Text(isEdit ? s.save : s.addCustomer),
            ),
          ),
        ],
      ),
    );
  }
}
