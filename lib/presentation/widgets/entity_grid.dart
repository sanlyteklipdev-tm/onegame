import 'package:flutter/material.dart';

/// Sanawlaryň umumy gönüburçluk gözenegi — stollar ekrany bilen deň
/// ölçegler, şonuň üçin ähli sanawlar birmeňzeş görünýär.
class EntityGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsets padding;
  final Future<void> Function()? onRefresh;

  /// Adaty gatnaşygyň ýerine öz gymmatlygyň. Kartda düwmeler bar bolsa
  /// beýiklik köpräk gerek — şonda şu ulanylýar.
  final double? childAspectRatio;

  /// Sütünleriň iň köp sany. Giň kartlar üçin çäklendirmek amatly.
  final int? maxCrossAxisCount;

  const EntityGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 100),
    this.onRefresh,
    this.childAspectRatio,
    this.maxCrossAxisCount,
  });

  static int crossAxisCount(double width, {int? max}) {
    final count = switch (width) {
      >= 1400 => 6,
      >= 1100 => 5,
      >= 850 => 4,
      >= 600 => 3,
      _ => 2,
    };
    return max == null ? count : (count > max ? max : count);
  }

  @override
  Widget build(BuildContext context) {
    final crossAxis = crossAxisCount(
      MediaQuery.sizeOf(context).width,
      max: maxCrossAxisCount,
    );

    final grid = GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxis,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // >1 — kart beýikliginden giň, ýagny gönüburçluk
        childAspectRatio:
            childAspectRatio ?? (crossAxis >= 3 ? 1.45 : 1.3),
      ),
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );

    final refresh = onRefresh;
    if (refresh == null) return grid;
    return RefreshIndicator(onRefresh: refresh, child: grid);
  }
}
