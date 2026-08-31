import 'package:flutter/material.dart';

/// Sanawlaryň umumy gönüburçluk gözenegi — stollar ekrany bilen deň
/// ölçegler, şonuň üçin ähli sanawlar birmeňzeş görünýär.
class EntityGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsets padding;
  final Future<void> Function()? onRefresh;

  const EntityGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 100),
    this.onRefresh,
  });

  static int crossAxisCount(double width) {
    if (width >= 1400) return 6;
    if (width >= 1100) return 5;
    if (width >= 850) return 4;
    if (width >= 600) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final crossAxis = crossAxisCount(MediaQuery.sizeOf(context).width);

    final grid = GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxis,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // >1 — kart beýikliginden giň, ýagny gönüburçluk
        childAspectRatio: crossAxis >= 3 ? 1.45 : 1.3,
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );

    final refresh = onRefresh;
    if (refresh == null) return grid;
    return RefreshIndicator(onRefresh: refresh, child: grid);
  }
}
