import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/utils/barcode_generator.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/price_calculator.dart';
import '../../data/models/player_session_model.dart';
import '../../data/models/table_model.dart';
import '../providers/providers.dart';
import 'package:barcode_widget/barcode_widget.dart';
import '../../core/services/printer_service.dart';

class CheckoutSheet extends ConsumerStatefulWidget {
  final PlayerSessionModel session;
  final TableModel table;
  final int activeCount;

  const CheckoutSheet({
    super.key,
    required this.session,
    required this.table,
    required this.activeCount,
  });

  @override
  ConsumerState<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<CheckoutSheet> {
  bool _isConfirming = false;
  StopResult? _result;

  double get _previewCost {
    if (_result != null) return _result!.totalPrice;
    final raw = PriceCalculator.currentSessionCost(
      accumulatedCost: widget.session.accumulatedCost,
      lastCheckpointTime: widget.session.lastCheckpointTime,
      pricePerHour: widget.table.pricePerHour,
      currentActiveCount: widget.activeCount,
    );
    final discount = widget.session.discountPercentage;
    return raw - (raw * discount / 100.0);
  }

  double get _rawCost {
    if (_result != null) return _result!.rawPrice;
    return PriceCalculator.currentSessionCost(
      accumulatedCost: widget.session.accumulatedCost,
      lastCheckpointTime: widget.session.lastCheckpointTime,
      pricePerHour: widget.table.pricePerHour,
      currentActiveCount: widget.activeCount,
    );
  }

  double get _discountPercentage =>
      _result?.discountPercentage ?? widget.session.discountPercentage;

  double get _discountAmount =>
      _result?.discountAmount ?? (_rawCost * _discountPercentage / 100.0);

  Duration get _duration {
    if (_result != null) return _result!.duration;
    return DateTime.now().difference(widget.session.startTime);
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
                    : CupertinoIcons.doc_text,
                size: 28,
                color: confirmed ? Colors.green.shade600 : scheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                confirmed ? s.confirmed : s.checkout,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (!confirmed)
                IconButton(
                  icon: const Icon(CupertinoIcons.xmark),
                  onPressed: () => Navigator.pop(context),
                ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withAlpha(102), // 0.4 * 255
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant.withAlpha(102)), // 0.4 * 255
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: CupertinoIcons.person_fill,
                  label: s.customer,
                  value: widget.session.playerName,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: CupertinoIcons.number,
                  label: s.code,
                  value: widget.session.sessionCode,
                  valueStyle: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: CupertinoIcons.table,
                  label: s.table,
                  value: widget.table.name,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: CupertinoIcons.clock,
                  label: s.started,
                  value: AppFormatters.formatDateTime(widget.session.startTime),
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: CupertinoIcons.timer,
                  label: s.duration,
                  value: AppFormatters.formatDuration(_duration),
                  valueStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scheme.primary,
                  ),
                ),
                if (widget.activeCount > 1) ...[
                  const SizedBox(height: 10),
                  _InfoRow(
                    icon: CupertinoIcons.person_2_fill,
                    label: s.playersAtTable,
                    value: s.playersSplit(widget.activeCount),
                  ),
                ],
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
                if (_discountPercentage > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.priceLabel,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: confirmed ? Colors.green.shade800 : scheme.onPrimaryContainer,
                          )),
                      Text(
                        AppFormatters.formatPrice(_rawCost, s.tmt),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: confirmed ? Colors.green.shade800 : scheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${s.discount} (${_discountPercentage.toStringAsFixed(0)}%):',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green.shade600,
                        ),
                      ),
                      Text(
                        '- ${AppFormatters.formatPrice(_discountAmount, s.tmt)}',
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
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
    setState(() => _isConfirming = true);
    try {
      final result = await ref
          .read(sessionNotifierProvider.notifier)
          .stopPlayer(
            sessionId: widget.session.id,
            tableId: widget.table.id,
            tableName: widget.table.name,
            pricePerHour: widget.table.pricePerHour,
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
      builder: (_) => _ReceiptView(
        result: _result!,
        tableName: widget.table.name,
        tableId: widget.table.id,
        pricePerHour: widget.table.pricePerHour,
      ),
    );
  }
}

class _ReceiptView extends ConsumerWidget {
  final StopResult result;
  final String tableName;
  final int tableId;
  final double pricePerHour;

  const _ReceiptView({
    required this.result,
    required this.tableName,
    required this.tableId,
    required this.pricePerHour,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final s = S.of(context);

    final activeSessionsAsync = ref.watch(activeSessionsProvider(tableId));
    final breakdown = <_PlayerBreakdown>[
      _PlayerBreakdown(
        name: result.playerName,
        duration: result.duration,
        price: result.totalPrice,
      ),
    ];
    activeSessionsAsync.whenData((sessions) {
      final activeCount = sessions.length;
      final now = DateTime.now();
      for (final session in sessions) {
        final price = PriceCalculator.currentSessionCost(
          accumulatedCost: session.accumulatedCost,
          lastCheckpointTime: session.lastCheckpointTime,
          pricePerHour: pricePerHour,
          currentActiveCount: activeCount,
        );
        breakdown.add(
          _PlayerBreakdown(
            name: session.playerName,
            duration: now.difference(session.startTime),
            price: price,
          ),
        );
      }
    });

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
                  AppFormatters.formatDateTime(result.endTime),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _ReceiptRow(s.customerLabel, result.playerName),
                const SizedBox(height: 6),
                _ReceiptRow(s.codeLabel, result.sessionCode),
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

                if (result.hasDiscount) ...[
                  _ReceiptRow(
                    s.priceLabel,
                    AppFormatters.formatPrice(result.rawPrice, s.tmt),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${s.discount} (${result.discountPercentage.toStringAsFixed(0)}%):',
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
                    data: BarcodeGenerator.generateAkhasapPayload(
                      result.duration,
                    ),
                    width: 200,
                    height: 80,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.black,
                    ),
                    errorBuilder: (context, error) =>
                        Center(child: Text(error)),
                  ),
                ),

                const SizedBox(height: 16),
                Text(s.thankYou, style: Theme.of(context).textTheme.bodyMedium),

                if (breakdown.length > 1) ...[
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
                    children: breakdown
                        .map(
                          (p) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    p.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    AppFormatters.formatDuration(p.duration),
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
                                    AppFormatters.formatPrice(p.price, s.tmt),
                                    textAlign: TextAlign.end,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
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
                      tableName: tableName,
                      startTime: AppFormatters.formatTime(result.startTime),
                      endTime: AppFormatters.formatTime(result.endTime),
                      duration: AppFormatters.formatDuration(result.duration),
                      totalAmount: result.totalPrice,
                      rawAmount: result.rawPrice,
                      discountPercentage: result.discountPercentage,
                      discountAmount: result.discountAmount,
                      players: breakdown.map((p) => p.name).toList(),
                      barcode: BarcodeGenerator.generateAkhasapPayload(
                        result.duration,
                      ),
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

class _PlayerBreakdown {
  final String name;
  final Duration duration;
  final double price;

  const _PlayerBreakdown({
    required this.name,
    required this.duration,
    required this.price,
  });
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