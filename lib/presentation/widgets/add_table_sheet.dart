import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../data/models/table_model.dart';
import '../providers/providers.dart';

class AddTableSheet extends ConsumerStatefulWidget {
  final TableModel? editingTable;
  const AddTableSheet({super.key, this.editingTable});

  @override
  ConsumerState<AddTableSheet> createState() => _AddTableSheetState();
}

class _AddTableSheetState extends ConsumerState<AddTableSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  final _formKey = GlobalKey<FormState>();
  bool _isFeatureEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.editingTable?.name ?? '',
    );
    _priceController = TextEditingController(
      text: widget.editingTable?.pricePerHour.toString() ?? '60',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final name = _nameController.text.trim();
      // 'nan'/'infinity' hem san hökmünde okalýar — beýle baha bazany
      // döwýär, şonuň üçin diňe çäkli sanlar kabul edilýär.
      final parsed = _isFeatureEnabled
          ? double.tryParse(_priceController.text.trim()) ?? 0.0
          : 0.0;
      final price = parsed.isFinite ? parsed : 0.0;

      if (widget.editingTable != null) {
        final updated = widget.editingTable!
          ..name = name
          ..pricePerHour = price;
        await ref.read(tableNotifierProvider.notifier).updateTable(updated);
      } else {
        await ref
            .read(tableNotifierProvider.notifier)
            .createTable(name: name, pricePerHour: price, maxUsers: null);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).errorPrefix}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: Form(
        key: _formKey,
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
            const SizedBox(height: 24),

            Text(
              widget.editingTable != null ? s.editTable : s.addNewTable,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),

            Text(s.tableName, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: s.tableNameHint,
                prefixIcon: const Icon(CupertinoIcons.tag, size: 18),
              ),
              validator: (v) => v == null || v.isEmpty ? s.enterName : null,
            ),
            const SizedBox(height: 20),

            Text(s.pricePerHour, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),

            // в State-классе добавь переменную:

            // ...
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    enabled: _isFeatureEnabled,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: '60',
                      prefixIcon: Icon(
                        CupertinoIcons.money_dollar,
                        size: 18,
                        color: _isFeatureEnabled ? null : Colors.grey,
                      ),
                      filled: true,
                      fillColor: _isFeatureEnabled
                          ? null
                          : Colors.grey.withAlpha(40),
                    ),
                    validator: (v) {
                      if (!_isFeatureEnabled) return null;
                      if (v == null || v.isEmpty) return s.enterPrice;
                      // 'nan' we 'infinity' tryParse-den geçýär — kesilýär
                      final n = double.tryParse(v);
                      if (n == null || !n.isFinite) return s.invalidNumber;
                      return null;
                    },
                  ),
                ),
                // Checkbox(
                //   value: _isFeatureEnabled,
                //   onChanged: (v) {
                //     setState(() {
                //       _isFeatureEnabled = v ?? false;
                //     });
                //   },
                // ),
              ],
            ),
            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: _isLoading ? null : _submit,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(CupertinoIcons.add),
              label: Text(widget.editingTable != null ? s.save : s.add),
            ),
          ],
        ),
      ),
    );
  }
}