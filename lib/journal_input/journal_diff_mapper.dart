import 'package:yourwish_kentei/yourwish_kentei.dart';

import 'journal_input_state.dart';

/// [judgeJournal] の結果（行の対応関係を持たない）を、入力テーブルの
/// セル位置（行番号・貸借・科目/金額）に割り当てる。
///
/// 正解側にしかない行（[JournalLineDiffKind.missing]）はテーブル上に表示する
/// セルがないため割り当てない（結果パネル側でテキストとして示す）。
Map<JournalCellRef, JournalLineDiffKind> buildCellDiffs(
  List<JournalLineInputRow> rows,
  List<JournalLineDiff> diffs,
) {
  final debitRows = <int>[];
  final creditRows = <int>[];
  for (var i = 0; i < rows.length; i++) {
    if (rows[i].debitAccount != null && rows[i].debitAmount != null) debitRows.add(i);
    if (rows[i].creditAccount != null && rows[i].creditAmount != null) creditRows.add(i);
  }

  final usedDebit = <int>{};
  final usedCredit = <int>{};
  final map = <JournalCellRef, JournalLineDiffKind>{};

  for (final diff in diffs) {
    final actual = diff.actual;
    if (actual == null) continue;
    final candidates = actual.side == JournalSide.debit ? debitRows : creditRows;
    final used = actual.side == JournalSide.debit ? usedDebit : usedCredit;
    final rowIndex = candidates.firstWhere(
      (i) =>
          !used.contains(i) &&
          (actual.side == JournalSide.debit
              ? rows[i].debitAccount == actual.account && rows[i].debitAmount == actual.amount
              : rows[i].creditAccount == actual.account && rows[i].creditAmount == actual.amount),
      orElse: () => -1,
    );
    if (rowIndex == -1) continue;
    used.add(rowIndex);
    map[JournalCellRef(rowIndex: rowIndex, side: actual.side, field: JournalCellField.account)] = diff.kind;
    map[JournalCellRef(rowIndex: rowIndex, side: actual.side, field: JournalCellField.amount)] = diff.kind;
  }
  return map;
}
