import 'package:yourwish_kentei/yourwish_kentei.dart';

import 'ledger_input_state.dart';

/// [judgeLedger] の結果を、入力テーブルのセル位置（記入行×列グループ×項目）に
/// 割り当てる。ledgerはセル位置が一意に対応するため、journalの行マッチングの
/// ような複雑な処理は不要（[buildWorksheetCellDiffs] と同じパターン）。
Map<LedgerCellRef, LedgerCellDiffKind> buildLedgerCellDiffs(List<LedgerCellDiff> diffs) {
  final map = <LedgerCellRef, LedgerCellDiffKind>{};
  for (final diff in diffs) {
    final expected = diff.expected;
    if (expected == null) continue;
    map[(expected.rowIndex, expected.group, expected.field)] = diff.kind;
  }
  return map;
}
