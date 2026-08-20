import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../data/models/customer_model.dart';
import '../providers/providers.dart';

class AddSessionSheet extends ConsumerStatefulWidget {
  final int tableId;
  const AddSessionSheet({super.key, required this.tableId});

  @override
  ConsumerState<AddSessionSheet> createState() => _AddSessionSheetState();
}

class _PlayerRowData {
  final TextEditingController controller;
  CustomerModel? selectedCustomer;

  _PlayerRowData({required this.controller}) {
    // If a customer is pre-selected, we could set the name,
    // but usually it starts empty.
  }

  void dispose() {
    controller.dispose();
  }
}

class _AddSessionSheetState extends ConsumerState<AddSessionSheet> {
  final List<_PlayerRowData> _playerRows = [];
  final _reminderController = TextEditingController(text: '60');
  bool _isFeatureEnabled = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _playerRows.add(_PlayerRowData(controller: TextEditingController()));
  }

  @override
  void dispose() {
    for (var row in _playerRows) {
      row.dispose();
    }
    _reminderController.dispose();
    super.dispose();
  }

  void _addPlayerInput() {
    setState(() {
      _playerRows.add(_PlayerRowData(controller: TextEditingController()));
    });
  }

  void _removePlayerInput(int index) {
    if (_playerRows.length > 1) {
      setState(() {
        _playerRows[index].dispose();
        _playerRows.removeAt(index);
      });
    }
  }

  Future<void> _submit() async {
    final s = S.of(context);
    setState(() => _isLoading = true);
    try {
      int? reminderMinutes;
      if (_reminderController.text.trim().isNotEmpty) {
        reminderMinutes = int.tryParse(_reminderController.text.trim());
      }

      for (var row in _playerRows) {
        String name = row.controller.text.trim();
        // If name is empty and a customer is selected, use the customer's name
        if (name.isEmpty && row.selectedCustomer != null) {
          name = row.selectedCustomer!.name;
        }

        await ref
            .read(sessionNotifierProvider.notifier)
            .addPlayer(
              tableId: widget.tableId,
              playerName: name.isEmpty ? s.defaultPlayerName : name,
              reminderMinutes: _isFeatureEnabled ? reminderMinutes : null,
              customerId: row.selectedCustomer?.id,
              discountPercentage:
                  row.selectedCustomer?.discountPercentage ?? 0.0,
            );
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final customersAsync = ref.watch(customersStreamProvider);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset + 16 : 32,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant.withAlpha(102),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  CupertinoIcons.person_add_solid,
                  color: scheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    s.addPlayerTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              s.activePlayers,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),

            customersAsync.when(
              data: (customers) => Column(
                children: List.generate(_playerRows.length, (index) {
                  final row = _playerRows[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PlayerInputRow(
                      index: index + 1,
                      row: row,
                      customers: customers,
                      onRemove: _playerRows.length > 1
                          ? () => _removePlayerInput(index)
                          : null,
                      isLast: index == _playerRows.length - 1,
                    ),
                  );
                }),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Error: $err'),
            ),

            Center(
              child: TextButton.icon(
                onPressed: _addPlayerInput,
                icon: const Icon(CupertinoIcons.add_circled),
                label: Text(s.addMore),
                style: TextButton.styleFrom(foregroundColor: scheme.primary),
              ),
            ),

            const SizedBox(height: 16),

            Text(s.reminder, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _reminderController,
                    enabled: _isFeatureEnabled,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '60',
                      suffixText: 'minut',
                      prefixIcon: Icon(
                        CupertinoIcons.timer,
                        size: 18,
                        color: _isFeatureEnabled ? null : Colors.grey,
                      ),
                      filled: true,
                      fillColor: _isFeatureEnabled
                          ? null
                          : Colors.grey.withAlpha(
                              40,
                            ),
                    ),
                  ),
                ),
                Checkbox(
                  value: _isFeatureEnabled,
                  onChanged: (v) {
                    setState(() {
                      _isFeatureEnabled = v ?? false;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
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
                    : const Icon(CupertinoIcons.play_arrow_solid),
                label: Text(s.confirmAndStart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerInputRow extends StatefulWidget {
  final int index;
  final _PlayerRowData row;
  final List<CustomerModel> customers;
  final VoidCallback? onRemove;
  final bool isLast;

  const _PlayerInputRow({
    required this.index,
    required this.row,
    required this.customers,
    this.onRemove,
    required this.isLast,
  });

  @override
  State<_PlayerInputRow> createState() => _PlayerInputRowState();
}

class _PlayerInputRowState extends State<_PlayerInputRow> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withAlpha(51),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${widget.index}',
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<CustomerModel?>(
                    value: widget.row.selectedCustomer,
                    isExpanded: true,
                    isDense: true,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    hint: Text(
                      s.noCustomer,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    items: [
                      DropdownMenuItem<CustomerModel?>(
                        value: null,
                        child: Text(s.noCustomer),
                      ),
                      ...widget.customers.map(
                        (c) => DropdownMenuItem<CustomerModel?>(
                          value: c,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  c.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (c.discountPercentage > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(30),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '-${c.discountPercentage.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      setState(() {
                        widget.row.selectedCustomer = val;
                      });
                    },
                  ),
                ),
              ),
              if (widget.onRemove != null)
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: widget.onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: widget.row.controller,
            autofocus: widget.isLast,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: widget.row.selectedCustomer != null
                  ? widget.row.selectedCustomer!.name
                  : s.playerNameHint,
              prefixIcon: Icon(
                CupertinoIcons.person,
                size: 18,
                color: scheme.primary.withAlpha(180),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              filled: true,
              fillColor: scheme.surface,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: scheme.outlineVariant.withAlpha(100),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: scheme.outlineVariant.withAlpha(100),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: scheme.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}