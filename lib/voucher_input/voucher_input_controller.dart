import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voucher_input_state.dart';

/// 入金伝票・出金伝票の入力状態を管理する（[JournalInputController] の
/// 簡易版。項目が相手科目・金額の2つだけなのでフォーカス移動も単純）。
class VoucherInputController extends Notifier<VoucherInputState> {
  @override
  VoucherInputState build() => const VoucherInputState();

  void reset() => state = const VoucherInputState();

  void selectField(VoucherSelectedField field) {
    state = state.copyWith(selectedField: () => field);
  }

  /// 相手科目を設定し、金額欄へ自動でフォーカスを移す。
  void setAccount(String accountCode) {
    state = state.copyWith(
      account: () => accountCode,
      selectedField: () => VoucherSelectedField.amount,
    );
  }

  void appendDigit(String digit) => _editAmount((current) {
        final next = (current ?? 0) * 10 + int.parse(digit);
        return next > 99999999 ? current : next;
      });

  void appendTripleZero() => _editAmount((current) {
        if (current == null) return null;
        final next = current * 1000;
        return next > 99999999 ? current : next;
      });

  void backspaceAmount() => _editAmount((current) {
        if (current == null || current < 10) return null;
        return current ~/ 10;
      });

  void clearAmount() => _editAmount((_) => null);

  /// 金額の入力を確定する（「次へ」ボタン用。項目がこれ以上ないのでフォーカスは外すだけ）。
  void confirmAmount() => state = state.copyWith(selectedField: () => null);

  void _editAmount(int? Function(int? current) edit) {
    if (state.selectedField != VoucherSelectedField.amount) return;
    state = state.copyWith(amount: () => edit(state.amount));
  }
}

final voucherInputProvider =
    NotifierProvider<VoucherInputController, VoucherInputState>(VoucherInputController.new);
