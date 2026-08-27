import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/models/customer_model.dart';
import '../../../providers/providers.dart';
import '../../../widgets/sheet_header.dart';
import '../../../widgets/sheet_submit_button.dart';

class CustomerFormSheet extends ConsumerStatefulWidget {
  final CustomerModel? existing;
  const CustomerFormSheet({super.key, this.existing});

  @override
  ConsumerState<CustomerFormSheet> createState() => _CustomerFormSheetState();
}

class _CustomerFormSheetState extends ConsumerState<CustomerFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _phoneCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _discountCtrl = TextEditingController(
        text: widget.existing?.discountPercentage.toStringAsFixed(0) ?? '0');
    _phoneCtrl = TextEditingController(text: widget.existing?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _discountCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = S.of(context);
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final discount = double.tryParse(_discountCtrl.text.trim()) ?? 0.0;

    setState(() => _isLoading = true);
    try {
      final phone = _phoneCtrl.text.trim();
      final customer = widget.existing ?? CustomerModel();
      customer.name = name;
      customer.discountPercentage = discount.clamp(0, 100);
      customer.phone = phone.isEmpty ? null : phone;
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
          SheetHeader(title: isEdit ? s.editCustomer : s.addCustomer),

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

          Text(s.phone, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: s.phoneOptional,
              prefixIcon: const Icon(CupertinoIcons.phone, size: 18),
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

          SheetSubmitButton(
            isLoading: _isLoading,
            isEdit: isEdit,
            label: isEdit ? s.save : s.addCustomer,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
