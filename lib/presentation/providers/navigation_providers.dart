import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Açyk duran bölümiň belgisi.
///
/// Öň bu san [HomeScreen]-iň içinde ýatyrdy, ýöne süýşýän menýu hem
/// ony üýtgetmeli — şonuň üçin daşyna çykaryldy.
class HomeTabIndex extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) => state = index;
}

final homeTabIndexProvider = NotifierProvider<HomeTabIndex, int>(
  HomeTabIndex.new,
);
