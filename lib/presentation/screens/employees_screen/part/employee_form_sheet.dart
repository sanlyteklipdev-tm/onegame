import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../data/models/employee_model.dart';
import '../../../providers/providers.dart';
import '../../../widgets/sheet_header.dart';
import '../../../widgets/sheet_submit_button.dart';

class EmployeeFormSheet extends ConsumerStatefulWidget {
  final EmployeeModel? existing;
  const EmployeeFormSheet({super.key, this.existing});

  @override
  ConsumerState<EmployeeFormSheet> createState() => _EmployeeFormSheetState();
}

class _EmployeeFormSheetState extends ConsumerState<EmployeeFormSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late EmployeeCategory _category;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.existing?.phone ?? '');
    _category = widget.existing?.category ?? EmployeeCategory.a;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final phone = _phoneCtrl.text.trim();

    setState(() => _isLoading = true);
    try {
      final employee = widget.existing ?? EmployeeModel();
      if (widget.existing == null) employee.createdAt = DateTime.now();
      employee
        ..name = name
        ..phone = phone.isEmpty ? null : phone
        ..category = _category;

      await ref.read(employeeNotifierProvider.notifier).saveEmployee(employee);
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('${s.errorPrefix}: $e')));
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
          SheetHeader(title: isEdit ? s.editEmployee : s.addEmployee),

          Text(s.employeeName, style: Theme.of(context).textTheme.labelLarge),
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

          Text(
            s.employeeCategory,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          SegmentedButton<EmployeeCategory>(
            segments: EmployeeCategory.values
                .map(
                  (c) => ButtonSegment(value: c, label: Text(c.label)),
                )
                .toList(),
            selected: {_category},
            onSelectionChanged: (set) =>
                setState(() => _category = set.first),
          ),

          const SizedBox(height: 32),

          SheetSubmitButton(
            isLoading: _isLoading,
            isEdit: isEdit,
            label: isEdit ? s.save : s.addEmployee,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
