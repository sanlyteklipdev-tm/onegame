import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Ýazgynyň haýsy enjamdan goşulandygyny görkezýän kiçi bellik.
///
/// Enjam belli däl bolsa (köne ýazgylar) hiç zat görkezilmeýär —
/// sanawlar boş bellikler bilen dolmaz ýaly.
class DeviceChip extends StatelessWidget {
  final String? deviceName;
  final bool dense;

  const DeviceChip({super.key, required this.deviceName, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final name = deviceName?.trim();
    if (name == null || name.isEmpty) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          CupertinoIcons.device_desktop,
          size: dense ? 11 : 13,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: dense ? 10.5 : 12,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
