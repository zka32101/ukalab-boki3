import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ledger_input_state.dart';

/// 補助簿（商品有高帳・現金出納帳など）入力テーブルの状態を管理する。
/// [WorksheetInputController]（`lib/worksheet_input/`）と同じパターン。
class LedgerInputController extends Notifier<LedgerInputState> {
  @override
  LedgerInputState build() => const LedgerInputState(editableCells: []);

  /// 問題の入力可能セル（[LedgerAnswer.blankCells] の位置）で初期化する。
  void initFor(List<LedgerCellRef> editableCells) {
    state = LedgerInputState.initial(editableCells);
  }

  void selectCell(LedgerCellRef cell) {
    if (!state.isEditable(cell)) return;
    state = state.copyWith(selectedCell: () => cell);
  }

  void appendDigit(String digit) => _editValue((current) {
        final next = (current ?? 0) * 10 + int.parse(digit);
        // 値の桁数上限（暫定8桁）で入力ミスの暴走を防ぐ。
        return next > 99999999 ? current : next;
      });

  /// `000` キー（3桁一括）。
  void appendTripleZero() => _editValue((current) {
        if (current == null) return null;
        final next = current * 1000;
        return next > 99999999 ? current : next;
      });

  /// 末尾の1桁を消す。
  void backspaceAmount() => _editValue((current) {
        if (current == null || current < 10) return null;
        return current ~/ 10;
      });

  void clearAmount() => _editValue((_) => null);

  void _editValue(int? Function(int? current) edit) {
    final cell = state.selectedCell;
    if (cell == null) return;
    final next = edit(state.values[cell]);
    final values = {...state.values};
    if (next == null) {
      values.remove(cell);
    } else {
      values[cell] = next;
    }
    state = state.copyWith(values: values);
  }

  /// 値の入力を確定し、次の未入力セルへ自動でフォーカスを移す（「次へ」ボタン用）。
  void confirmAmount() {
    final cell = state.selectedCell;
    if (cell == null) return;
    final index = state.editableCells.indexOf(cell);
    for (var i = index + 1; i < state.editableCells.length; i++) {
      final next = state.editableCells[i];
      if (!state.values.containsKey(next)) {
        state = state.copyWith(selectedCell: () => next);
        return;
      }
    }
    state = state.copyWith(selectedCell: () => null);
  }
}

final ledgerInputProvider =
    NotifierProvider<LedgerInputController, LedgerInputState>(LedgerInputController.new);
