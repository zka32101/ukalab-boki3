import 'package:flutter/material.dart';

import 'voucher_kind.dart';

/// 伝票1枚分の見た目（実物の伝票の配色に合わせる。入金伝票は赤系、
/// 出金伝票は青系、振替伝票は黒系の用紙を使うのが一般的）。
class VoucherSlipFrame extends StatelessWidget {
  const VoucherSlipFrame({super.key, required this.kind, required this.child});

  final VoucherKind kind;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final (background, accent) = _colorsFor(kind);
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: accent, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              kind.label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  (Color, Color) _colorsFor(VoucherKind kind) => switch (kind) {
        VoucherKind.receipt => (Colors.red.shade50, Colors.red.shade400),
        VoucherKind.payment => (Colors.blue.shade50, Colors.blue.shade400),
        VoucherKind.transfer => (Colors.grey.shade200, Colors.grey.shade700),
      };
}
