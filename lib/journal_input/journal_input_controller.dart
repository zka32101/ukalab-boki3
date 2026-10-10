import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ukalab_core/ukalab_core.dart';

import 'journal_input_state.dart';

/// 仕訳入力テーブルの状態を管理する。履歴の記録・自動フォーカス移動・
/// Undoを担う（画面側は見た目のみ）。
class JournalInputController extends Notifier<JournalInputState> {
  @override
  JournalInputState build() => JournalInputState.initial();

  void reset({int rowCount = 1}) => state = JournalInputState.initial(rowCount: rowCount);

  void selectCell(JournalCellRef cell) {
    state = state.copyWith(selectedCell: () => cell);
  }

  void clearSelection() {
    state = state.copyWith(selectedCell: () => null);
  }

  /// 科目セルに値を設定し、次のセルへ自動でフォーカスを移す。
  void setAccount(String accountCode) {
    final cell = state.selectedCell;
    if (cell == null || cell.field != JournalCellField.account) return;
    _applyToRow(cell.rowIndex, (row) {
      return cell.side == JournalSide.debit
          ? row.copyWith(debitAccount: () => accountCode)
          : row.copyWith(creditAccount: () => accountCode);
    });
    _advanceFocus(cell);
  }

  /// テンキーの数字（`0`〜`9`）を金額セルの末尾に追加する。
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
    if (cell == null || cell.field != JournalCellField.amount) return;
    _applyToRow(cell.rowIndex, (row) {
      final current = cell.side == JournalSide.debit ? row.debitAmount : row.creditAmount;
      final next = edit(current);
      return cell.side == JournalSide.debit
          ? row.copyWith(debitAmount: () => next)
          : row.copyWith(creditAmount: () => next);
    });
  }

  /// 金額の入力を確定し、次のセルへ自動でフォーカスを移す（「次へ」ボタン用）。
  void confirmAmount() {
    final cell = state.selectedCell;
    if (cell == null || cell.field != JournalCellField.amount) return;
    _advanceFocus(cell);
  }

  void addRow() {
    if (state.rows.length >= JournalInputState.maxRows) return;
    _pushHistory();
    state = state.copyWith(rows: [...state.rows, const JournalLineInputRow()]);
  }

  void removeRow(int index) {
    if (state.rows.length <= 1) return;
    _pushHistory();
    final rows = [...state.rows]..removeAt(index);
    state = state.copyWith(rows: rows, selectedCell: () => null);
  }

  void undo() {
    if (state.history.isEmpty) return;
    final history = [...state.history];
    final previous = history.removeLast();
    state = state.copyWith(rows: previous, history: history, selectedCell: () => null);
  }

  void _applyToRow(int rowIndex, JournalLineInputRow Function(JournalLineInputRow row) edit) {
    if (rowIndex < 0 || rowIndex >= state.rows.length) return;
    _pushHistory();
    final rows = [...state.rows];
    rows[rowIndex] = edit(rows[rowIndex]);
    state = state.copyWith(rows: rows);
  }

  void _pushHistory() {
    final history = [...state.history, state.rows];
    if (history.length > JournalInputState.maxHistory) history.removeAt(0);
    state = state.copyWith(history: history);
  }

  /// 借方科目 → 借方金額 → 貸方科目 → 貸方金額 → 次の行の借方科目 の順に進む。
  void _advanceFocus(JournalCellRef from) {
    final next = _nextCell(from);
    state = state.copyWith(selectedCell: () => next);
  }

  JournalCellRef? _nextCell(JournalCellRef from) {
    if (from.side == JournalSide.debit && from.field == JournalCellField.account) {
      return JournalCellRef(rowIndex: from.rowIndex, side: JournalSide.debit, field: JournalCellField.amount);
    }
    if (from.side == JournalSide.debit && from.field == JournalCellField.amount) {
      return JournalCellRef(rowIndex: from.rowIndex, side: JournalSide.credit, field: JournalCellField.account);
    }
    if (from.side == JournalSide.credit && from.field == JournalCellField.account) {
      return JournalCellRef(rowIndex: from.rowIndex, side: JournalSide.credit, field: JournalCellField.amount);
    }
    // credit/amount の次: 次の行があればその借方科目へ、なければ選択解除。
    final nextRow = from.rowIndex + 1;
    if (nextRow < state.rows.length) {
      return JournalCellRef(rowIndex: nextRow, side: JournalSide.debit, field: JournalCellField.account);
    }
    return null;
  }
}

final journalInputProvider =
    NotifierProvider<JournalInputController, JournalInputState>(JournalInputController.new);
