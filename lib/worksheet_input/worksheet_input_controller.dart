import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'worksheet_input_state.dart';

/// 表埋め（精算表・財務諸表）入力テーブルの状態を管理する。
class WorksheetInputController extends Notifier<WorksheetInputState> {
  @override
  WorksheetInputState build() => const WorksheetInputState(editableCells: []);

  /// 問題の入力可能セル（[WorksheetAnswer.blankCells] の位置）で初期化する。
  void initFor(List<WorksheetCellRef> editableCells) {
    state = WorksheetInputState.initial(editableCells);
  }

  void selectCell(WorksheetCellRef cell) {
    if (!state.isEditable(cell)) return;
    state = state.copyWith(selectedCell: () => cell);
  }

  void appendDigit(String digit) => _editAmount((current) {
        final next = (current ?? 0) * 10 + int.parse(digit);
        // 金額の桁数上限（暫定8桁。1億円未満）で入力ミスの暴走を防ぐ。
        return next > 99999999 ? current : next;
      });

  /// `000` キー（3桁一括）。
  void appendTripleZero() => _editAmount((current) {
        if (current == null) return null;
        final next = current * 1000;
        return next > 99999999 ? current : next;
      });

  /// 末尾の1桁を消す。
  void backspaceAmount() => _editAmount((current) {
        if (current == null || current < 10) return null;
        return current ~/ 10;
      });

  void clearAmount() => _editAmount((_) => null);

  void _editAmount(int? Function(int? current) edit) {
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

  /// 金額の入力を確定し、次の未入力セルへ自動でフォーカスを移す（「次へ」ボタン用）。
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

final worksheetInputProvider =
    NotifierProvider<WorksheetInputController, WorksheetInputState>(WorksheetInputController.new);
