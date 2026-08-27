import 'package:flutter/material.dart';

import '../../../../data/models/player_session_model.dart';
import '../../../../data/models/table_model.dart';
import '../../../widgets/add_session_sheet.dart';
import '../../../widgets/checkout_sheet.dart';
import '../../../widgets/close_table_sheet.dart';

void showAddSessionSheet(BuildContext context, TableModel table) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => AddSessionSheet(tableId: table.id),
  );
}

void showCheckoutSheet(
  BuildContext context,
  TableModel table,
  PlayerSessionModel session,
  int activeCount,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    builder: (_) => CheckoutSheet(
      session: session,
      table: table,
      activeCount: activeCount,
    ),
  );
}

void showCloseTableSheet(
  BuildContext context,
  TableModel table,
  List<PlayerSessionModel> activeSessions,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    builder: (_) =>
        CloseTableSheet(table: table, activeSessions: activeSessions),
  );
}
