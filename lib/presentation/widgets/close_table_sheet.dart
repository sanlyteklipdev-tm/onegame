 import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barcode_widget/barcode_widget.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/services/printer_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/price_calculator.dart';
import '../../core/utils/barcode_generator.dart';
import '../../data/models/player_session_model.dart';
import '../../data/models/table_model.dart';
import '../providers/providers.dart';

class CloseTableSheet extends ConsumerStatefulWidget {
  final TableModel table;
  final List<PlayerSessionModel> activeSessions;

  const CloseTableSheet({
    super.key,
    required this.table,
    required this.activeSessions,
  });

  @override
  ConsumerState<CloseTableSheet> createState() => _CloseTableSheetState();
}

class _CloseTableSheetState extends ConsumerState<CloseTableSheet> {
  bool _isConfirming = false;
  StopResult? _result;
  final TextEditingController _payerController = TextEditingController();

  double get _previewCost {
    if (_result != null) return _result!.totalPrice;
    return _rawCost - _totalDiscountAmount;
  }

  double get _rawCost {
    if (_result != null) return _result!.rawPrice;
    double total = 0;
    final now = DateTime.now();
    for (final s in widget.activeSessions) {
      final elapsed = now.difference(s.lastCheckpointTime);
      total +=
          s.accumulatedCost +
          PriceCalculator.segmentCostPerPlayer(
            pricePerHour: widget.table.pricePerHour,
            durationSeconds: elapsed.inMilliseconds / 1000.0,
            playerCount: widget.activeSessions.length,
          );
    }
    return total;
  }

  double get _totalDiscountAmount {
    if (_result != null) return _result!.discountAmount;
    double totalDisc = 0;
    final now = DateTime.now();
    for (final s in widget.activeSessions) {
      final elapsed = now.difference(s.lastCheckpointTime);
      final raw =
          s.accumulatedCost +
          PriceCalculator.segmentCostPerPlayer(
            pricePerHour: widget.table.pricePerHour,
            durationSeconds: elapsed.inMilliseconds / 1000.0,
            playerCount: widget.activeSessions.length,
          );
      totalDisc += (raw * s.discountPercentage / 100.0);
    }
    return totalDisc;
  }

  Duration get _longestDuration {
    if (_result != null) return _result!.duration;
    final now = DateTime.now();
    Duration longest = Duration.zero;
    for (final s in widget.activeSessions) {
      final d = now.difference(s.startTime);
      if (d > longest) longest = d;
    }
    return longest;
  }

  DateTime get _earliestStartTime {
    if (_result != null) return _result!.startTime;
    return widget.activeSessions
        .map((e) => e.startTime)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }

  @override
  void dispose() {
    _payerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final confirmed = _result != null;
    final s = S.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12,
      ),
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

          Row(
            children: [
              Icon(
                confirmed
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.rectangle_stack_person_crop_fill,
                size: 28,
                color: confirmed ? Colors.green.shade600 : scheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  confirmed ? s.confirmed : s.closeTotalTable,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (!confirmed)
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark),
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),

          const SizedBox(height: 20),

          if (!confirmed) ...[
            Text(
              s.closeTotalTablePrompt,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _payerController,
              decoration: InputDecoration(
                hintText: s.payerNameHint,
                prefixIcon: const Icon(CupertinoIcons.person_fill, size: 18),
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withAlpha(
                  128,
                ), // 0.5 * 255
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withAlpha(102), // 0.4 * 255
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scheme.outlineVariant.withAlpha(102),
              ), // 0.4 * 255
            ),
            child: Column(
              children: [
                if (confirmed) ...[
                  _InfoRow(
                    icon: CupertinoIcons.person_fill,
                    label: s.customer,
                    value: _result!.playerName,
                  ),
                  const SizedBox(height: 10),
                ],
                _InfoRow(
                  icon: CupertinoIcons.table,
                  label: s.table,
                  value: widget.table.name,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: CupertinoIcons.clock,
                  label: s.started,
                  value: AppFormatters.formatDateTime(_earliestStartTime),
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: CupertinoIcons.timer,
                  label: s.duration,
                  value: AppFormatters.formatDuration(_longestDuration),
                  valueStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: CupertinoIcons.person_2_fill,
                  label: s.playersAtTable,
                  value: s.personCount(widget.activeSessions.length),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: confirmed ? Colors.green.shade50 : scheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                if (_totalDiscountAmount > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.priceLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: confirmed
                              ? Colors.green.shade800
                              : scheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        AppFormatters.formatPrice(_rawCost, s.tmt),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: confirmed
                              ? Colors.green.shade800
                              : scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.discount,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade600,
                        ),
                      ),
                      Text(
                        '- ${AppFormatters.formatPrice(_totalDiscountAmount, s.tmt)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Divider(color: scheme.outlineVariant.withAlpha(80)),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      s.totalPayment,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: confirmed
                            ? Colors.green.shade800
                            : scheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      AppFormatters.formatPrice(_previewCost, s.tmt),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: confirmed
                                ? Colors.green.shade700
                                : scheme.onPrimaryContainer,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (!confirmed) ...[
            FilledButton.icon(
              onPressed: _isConfirming ? null : _confirm,
              icon: _isConfirming
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(CupertinoIcons.checkmark_circle),
              label: Text(_isConfirming ? s.calculating : s.confirm),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(CupertinoIcons.xmark, size: 16),
              label: Text(s.back),
            ),
          ] else ...[
            FilledButton.icon(
              onPressed: () => _showReceiptView(context),
              icon: const Icon(CupertinoIcons.printer),
              label: Text(s.showReceipt),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(CupertinoIcons.house, size: 16),
              label: Text(s.close),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirm() async {
    final s = S.of(context);
    setState(() => _isConfirming = true);
    try {
      final result = await ref
          .read(sessionNotifierProvider.notifier)
          .stopTable(
            tableId: widget.table.id,
            tableName: widget.table.name,
            pricePerHour: widget.table.pricePerHour,
            payerName: _payerController.text.trim().isEmpty
                ? s.generalCustomerName
                : _payerController.text.trim(),
          );
      setState(() {
        _result = result;
        _isConfirming = false;
      });
    } catch (e) {
      setState(() => _isConfirming = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).errorPrefix}: $e')),
        );
      }
    }
  }

  void _showReceiptView(BuildContext context) {
    if (_result == null) return;
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _TableReceiptView(
        result: _result!,
        tableName: widget.table.name,
        pricePerHour: widget.table.pricePerHour,
        playerNames: widget.activeSessions.map((s) => s.playerName).toList(),
      ),
    );
  }
}

class _TableReceiptView extends StatelessWidget {
  final StopResult result;
  final String tableName;
  final double pricePerHour;
  final List<String> playerNames;

  const _TableReceiptView({
    required this.result,
    required this.tableName,
    required this.pricePerHour,
    required this.playerNames,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

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
              border: Border.all(
                color: scheme.outlineVariant.withAlpha(102),
              ), // 0.4 * 255
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
                  AppFormatters.formatDateTime(result.endTime),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _ReceiptRow(s.customerLabel, result.playerName),
                const SizedBox(height: 6),
                _ReceiptRow(s.codeLabel, result.sessionCode), // 'TOPLUMLAÝYN'
                const SizedBox(height: 6),
                _ReceiptRow(s.tableLabel, tableName),
                const SizedBox(height: 6),
                _ReceiptRow(
                  s.startedLabel,
                  AppFormatters.formatTime(result.startTime),
                ),
                const SizedBox(height: 6),
                _ReceiptRow(
                  s.finishedLabel,
                  AppFormatters.formatTime(result.endTime),
                ),
                const SizedBox(height: 6),
                _ReceiptRow(
                  s.durationLabel,
                  AppFormatters.formatDuration(result.duration),
                ),
                const SizedBox(height: 6),
                _ReceiptRow(
                  s.priceLabel,
                  '${pricePerHour.toStringAsFixed(0)} ${s.perHourShort}',
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),

                if (result.discountAmount > 0) ...[
                  _ReceiptRow(
                    s.priceLabel,
                    AppFormatters.formatPrice(result.rawPrice, s.tmt),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        s.discount,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '- ${AppFormatters.formatPrice(result.discountAmount, s.tmt)}',
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
                      AppFormatters.formatPrice(result.totalPrice, s.tmt),
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
                    data: BarcodeGenerator.generateAkhasapPayload(result.duration),
                    width: 200,
                    height: 80,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black,
                    ),
                    errorBuilder: (context, error) => Center(child: Text(error)),
                  ),
                ),

                const SizedBox(height: 16),
                Text(s.thankYou, style: Theme.of(context).textTheme.bodyMedium),

                if (playerNames.length > 1) ...[
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
                    children: playerNames
                        .map(
                          (name) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

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
                      tableName: tableName,
                      startTime: AppFormatters.formatTime(result.startTime),
                      endTime: AppFormatters.formatTime(result.endTime),
                      duration: AppFormatters.formatDuration(result.duration),
                      totalAmount: result.totalPrice,
                      rawAmount: result.rawPrice,
                      discountAmount: result.discountAmount,
                      players: playerNames,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(message)));
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Text('$label ', style: Theme.of(context).textTheme.bodyMedium),
        Expanded(
          child: Text(
            value,
            style:
                valueStyle ??
                Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}