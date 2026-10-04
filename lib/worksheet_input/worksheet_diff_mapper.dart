import 'package:yourwish_kentei/yourwish_kentei.dart';

import 'worksheet_input_state.dart';

/// [judgeWorksheet] の結果を、入力テーブルのセル位置（勘定科目×列）に割り当てる。
/// worksheetはセル位置が一意に対応するため、journalの行マッチングのような
/// 複雑な処理は不要。
Map<WorksheetCellRef, WorksheetCellDiffKind> buildWorksheetCellDiffs(
  List<WorksheetCellDiff> diffs,
) {
  final map = <WorksheetCellRef, WorksheetCellDiffKind>{};
  for (final diff in diffs) {
    final expected = diff.expected;
    if (expected == null) continue;
    map[(expected.account, expected.column)] = diff.kind;
  }
  return map;
}
