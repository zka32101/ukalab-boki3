import 'package:yourwish_kentei/yourwish_kentei.dart';

/// 表埋め（精算表・財務諸表）入力中の1セルの位置（勘定科目コード × 列）。
typedef WorksheetCellRef = (String account, WorksheetColumn column);

/// 表埋め入力テーブル全体の状態。
///
/// [editableCells] が問題ごとの入力可能セル（[WorksheetAnswer.blankCells] の
/// 位置）。[values] はそのうち入力済みのセルの金額。
class WorksheetInputState {
  const WorksheetInputState({
    required this.editableCells,
    this.values = const {},
    this.selectedCell,
  });

  factory WorksheetInputState.initial(List<WorksheetCellRef> editableCells) =>
      WorksheetInputState(editableCells: editableCells);

  final List<WorksheetCellRef> editableCells;
  final Map<WorksheetCellRef, int> values;
  final WorksheetCellRef? selectedCell;

  bool isEditable(WorksheetCellRef cell) => editableCells.contains(cell);

  int? amountAt(WorksheetCellRef cell) => values[cell];

  /// 入力済みのセルだけを `WorksheetCell` のリストに変換する（採点に渡す用）。
  List<WorksheetCell> toWorksheetCells() => [
        for (final entry in values.entries)
          WorksheetCell(account: entry.key.$1, column: entry.key.$2, amount: entry.value),
      ];

  WorksheetInputState copyWith({
    List<WorksheetCellRef>? editableCells,
    Map<WorksheetCellRef, int>? values,
    WorksheetCellRef? Function()? selectedCell,
  }) =>
      WorksheetInputState(
        editableCells: editableCells ?? this.editableCells,
        values: values ?? this.values,
        selectedCell: selectedCell != null ? selectedCell() : this.selectedCell,
      );
}
