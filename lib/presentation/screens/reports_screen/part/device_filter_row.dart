import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../providers/providers.dart';

/// Enjam boýunça süzgüç. Ýazgylarda enjam bellenmedik bolsa
/// (köne ýazgylar) hiç zat görkezilmeýär.
class DeviceFilterRow extends ConsumerWidget {
  const DeviceFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(historyDevicesProvider);
    if (devices.isEmpty) return const SizedBox.shrink();

    final selected = ref.watch(reportDeviceFilterProvider);
    final notifier = ref.read(reportDeviceFilterProvider.notifier);
    final s = S.of(context);

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(s.allDevices),
              selected: selected == null,
              onSelected: (_) => notifier.select(null),
            ),
          ),
          ...devices.map(
            (d) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(d),
                selected: selected == d,
                onSelected: (_) => notifier.select(selected == d ? null : d),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
