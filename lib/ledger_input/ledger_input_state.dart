import 'package:yourwish_kentei/yourwish_kentei.dart';

/// 補助簿（商品有高帳・現金出納帳など）入力中の1セルの位置
/// （記入行インデックス × 列グループ × 項目）。
typedef LedgerCellRef = (int rowIndex, LedgerColumnGroup group, LedgerField field);

/// 補助簿入力テーブル全体の状態。
///
/// [editableCells] が問題ごとの入力可能セル（[LedgerAnswer.blankCells] の
/// 位置）。[values] はそのうち入力済みのセルの値。
class LedgerInputState {
  const LedgerInputState({
    required this.editableCells,
    this.values = const {},
    this.selectedCell,
  });

  factory LedgerInputState.initial(List<LedgerCellRef> editableCells) =>
      LedgerInputState(editableCells: editableCells);

  final List<LedgerCellRef> editableCells;
  final Map<LedgerCellRef, int> values;
  final LedgerCellRef? selectedCell;

  bool isEditable(LedgerCellRef cell) => editableCells.contains(cell);

  int? valueAt(LedgerCellRef cell) => values[cell];

  /// 入力済みのセルだけを `LedgerCell` のリストに変換する（採点に渡す用）。
  List<LedgerCell> toLedgerCells() => [
        for (final entry in values.entries)
          LedgerCell(
            rowIndex: entry.key.$1,
            group: entry.key.$2,
            field: entry.key.$3,
            value: entry.value,
          ),
      ];

  LedgerInputState copyWith({
    List<LedgerCellRef>? editableCells,
    Map<LedgerCellRef, int>? values,
    LedgerCellRef? Function()? selectedCell,
  }) =>
      LedgerInputState(
        editableCells: editableCells ?? this.editableCells,
        values: values ?? this.values,
        selectedCell: selectedCell != null ? selectedCell() : this.selectedCell,
      );
}
