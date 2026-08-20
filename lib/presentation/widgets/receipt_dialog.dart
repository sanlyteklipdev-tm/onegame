import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/barcode_generator.dart';
import '../../core/utils/price_calculator.dart';
import '../../core/services/printer_service.dart';
import '../../data/models/history_log_model.dart';
import '../providers/providers.dart';

class ReceiptDialog extends ConsumerWidget {
  final HistoryLogModel log;

  const ReceiptDialog({super.key, required this.log});

  static void show(BuildContext context, HistoryLogModel log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => ReceiptDialog(log: log),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);
    final duration = log.endTime.difference(log.startTime);

    final playersAsync = ref.watch(
      playersPlayedInWindowProvider(
        PlayersWindowQuery(
          tableId: log.tableId,
          start: log.startTime,
          end: log.endTime,
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant.withAlpha(102)), // 0.4 * 255
            ),
            child: Column(
              children: [
                Text(
                  s.receiptTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppFormatters.formatDateTime(log.endTime),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                
                _ReceiptRow(s.customerLabel, log.playerName),
                const SizedBox(height: 6),
                _ReceiptRow(s.codeLabel, log.sessionCode),
                const SizedBox(height: 6),
                _ReceiptRow(s.tableLabel, log.tableName),
                const SizedBox(height: 6),
                _ReceiptRow(s.startedLabel, AppFormatters.formatTime(log.startTime)),
                const SizedBox(height: 6),
                _ReceiptRow(s.finishedLabel, AppFormatters.formatTime(log.endTime)),
                const SizedBox(height: 6),
                _ReceiptRow(s.durationLabel, AppFormatters.formatDuration(duration)),
                
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                // Show discount if applicable
                if (log.discountPercentage != null && (log.discountPercentage ?? 0) > 0) ...[
                  _ReceiptRow(
                    s.priceLabel,
                    AppFormatters.formatPrice(
                        (log.totalPrice + (log.discountAmount ?? 0)), s.tmt),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${s.discount} (${log.discountPercentage!.toStringAsFixed(0)}%):',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '- ${AppFormatters.formatPrice(log.discountAmount ?? 0, s.tmt)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.totalPaymentLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      AppFormatters.formatPrice(log.totalPrice, s.tmt),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // AKHASAP CODE-128 BARCODE
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: BarcodeGenerator.generateAkhasapPayload(duration),
                    width: 200,
                    height: 80,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black),
                    errorBuilder: (context, error) => Center(child: Text(error)),
                  ),
                ),
                
                const SizedBox(height: 16),
                Text(s.thankYou, style: Theme.of(context).textTheme.bodyMedium),

                playersAsync.when(
                  data: (sessions) {
                    if (sessions.length <= 1) return const SizedBox.shrink();
                    final now = DateTime.now();
                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            s.players,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: sessions
                              .map((session) {
                                final playerDuration = session.isFinished
                                    ? (session.endTime ?? now).difference(session.startTime)
                                    : now.difference(session.startTime);
                                final playerPrice = session.isFinished
                                    ? session.totalPrice
                                    : session.accumulatedCost;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          session.playerName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          AppFormatters.formatDuration(playerDuration),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          AppFormatters.formatPrice(playerPrice, s.tmt),
                                          textAlign: TextAlign.end,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(CupertinoIcons.xmark, size: 16),
                  label: Text(s.close),
                ),
              ),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final message = await PrinterService().printReceipt(
                      tableName: log.tableName,
                      startTime: AppFormatters.formatTime(log.startTime),
                      endTime: AppFormatters.formatTime(log.endTime),
                      duration: AppFormatters.formatDuration(duration),
                      totalAmount: log.totalPrice,
                      rawAmount: log.totalPrice + (log.discountAmount ?? 0),
                      discountAmount: log.discountAmount ?? 0,
                      players: playersAsync.maybeWhen(
                        data: (sessions) => sessions.isNotEmpty
                            ? sessions.map((s) => s.playerName).toList()
                            : [log.playerName],
                        orElse: () => [log.playerName],
                      ),
                      barcode: BarcodeGenerator.generateAkhasapPayload(duration),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(message)),
                      );
                    }
                  },
                  icon: const Icon(CupertinoIcons.printer, size: 16),
                  label: const Text('Çap et'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReceiptRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}