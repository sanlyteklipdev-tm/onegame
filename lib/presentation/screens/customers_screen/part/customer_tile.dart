import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/models/customer_model.dart';
import '../../../providers/providers.dart';
import 'customer_form_sheet.dart';

class CustomerTile extends ConsumerWidget {
  final CustomerModel customer;
  const CustomerTile({super.key, required this.customer});

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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (customer.discountPercentage > 0)
              Row(
                children: [
                  Icon(CupertinoIcons.tag, size: 13, color: Colors.green.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${s.discount}: ${customer.discountPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w500),
                  ),
                ],
              )
            else
              Text(s.noDiscount, style: TextStyle(color: scheme.onSurfaceVariant)),
            if (customer.phone != null && customer.phone!.isNotEmpty)
              Row(
                children: [
                  Icon(CupertinoIcons.phone, size: 13, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    customer.phone!,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(CupertinoIcons.pencil, size: 18),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                builder: (_) => CustomerFormSheet(existing: customer),
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
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
            ),
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
