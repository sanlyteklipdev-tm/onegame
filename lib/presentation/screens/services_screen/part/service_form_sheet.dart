import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/models/service_model.dart';
import '../../../providers/providers.dart';
import '../../../widgets/sheet_header.dart';
import '../../../widgets/sheet_submit_button.dart';

class ServiceFormSheet extends ConsumerStatefulWidget {
  final ServiceModel? existing;
  const ServiceFormSheet({super.key, this.existing});

  @override
  ConsumerState<ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends ConsumerState<ServiceFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _priceCtrl = TextEditingController(
      text: widget.existing?.price.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    void showError(String text) => messenger.showSnackBar(
      SnackBar(content: Text(text), backgroundColor: errorColor),
    );

    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      showError(s.enterName);
      return;
    }

    // 'nan'/'infinity' hem san hökmünde okalýar — diňe çäkli sanlar
    final parsed = double.tryParse(_priceCtrl.text.trim());
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      showError(s.invalidNumber);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final service = widget.existing ?? ServiceModel();
      if (widget.existing == null) service.createdAt = DateTime.now();
      service
        ..name = name
        ..price = parsed;

      await ref.read(serviceNotifierProvider.notifier).saveService(service);
      navigator.pop();
    } catch (e) {
      showError('${s.errorPrefix}: $e');
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
          SheetHeader(title: isEdit ? s.editService : s.addService),

          Text(s.serviceName, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: s.serviceNameHint,
              prefixIcon: const Icon(CupertinoIcons.sparkles, size: 18),
            ),
          ),

          const SizedBox(height: 16),

          Text(s.servicePrice, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: s.tmt,
              prefixIcon: const Icon(CupertinoIcons.money_dollar, size: 18),
            ),
          ),

          const SizedBox(height: 32),

          SheetSubmitButton(
            isLoading: _isLoading,
            isEdit: isEdit,
            label: isEdit ? s.save : s.addService,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
