import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/service_model.dart';
import '../../providers/providers.dart';
import '../../widgets/entity_card.dart';
import '../../widgets/entity_grid.dart';
import 'part/service_form_sheet.dart';
import '../home_screen/part/home_drawer.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showForm([ServiceModel? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ServiceFormSheet(existing: existing),
    );
  }

  void _confirmDelete(ServiceModel service, S s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteService),
        content: Text(s.deleteServiceConfirm(service.name)),
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
                  .read(serviceNotifierProvider.notifier)
                  .deleteService(service.id);
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
    final servicesAsync = ref.watch(servicesStreamProvider);
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
                ),
                style: const TextStyle(fontSize: 18),
                onChanged: (_) => setState(() {}),
              )
            : Text(s.services),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? CupertinoIcons.xmark : CupertinoIcons.search,
            ),
            onPressed: () => setState(() {
              if (_isSearching) _searchCtrl.clear();
              _isSearching = !_isSearching;
            }),
          ),
        ],
      ),
      body: servicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${s.errorPrefix}: $e')),
        data: (services) {
          final query = _searchCtrl.text.toLowerCase().trim();
          final filtered = services
              .where((x) => x.name.toLowerCase().contains(query))
              .toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSearching
                        ? CupertinoIcons.search
                        : CupertinoIcons.sparkles,
                    size: 64,
                    color: scheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching ? s.noResults : s.noServices,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSearching ? s.tryDifferentSearch : s.noServicesHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }

          return EntityGrid(
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final service = filtered[i];
              return EntityCard(
                name: service.name,
                icon: CupertinoIcons.sparkles,
                badge: AppFormatters.formatPrice(service.price, s.tmt),
                deviceName: service.deviceName,
                onEdit: () => _showForm(service),
                onDelete: () => _confirmDelete(service, s),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'service-add',
        onPressed: _showForm,
        icon: const Icon(CupertinoIcons.add),
        label: Text(s.addService),
      ),
    );
  }
}
