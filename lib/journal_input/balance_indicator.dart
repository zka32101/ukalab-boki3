import 'package:flutter/material.dart';

/// 借方・貸方の合計をリアルタイム表示する。正誤ではなく「貸借が合っているか」の
/// ヒントのみ（答え合わせの結果とは別）。
class BalanceIndicator extends StatelessWidget {
  const BalanceIndicator({
    super.key,
    required this.debitTotal,
    required this.creditTotal,
  });

  final int debitTotal;
  final int creditTotal;

  bool get _balanced => debitTotal == creditTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _balanced ? theme.colorScheme.primary : theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_balanced ? Icons.check_circle_outline : Icons.error_outline, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _balanced
                  ? '借方・貸方が一致しています（$debitTotal）'
                  : '借方($debitTotal)と貸方($creditTotal)が一致していません',
              style: theme.textTheme.bodyMedium?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
