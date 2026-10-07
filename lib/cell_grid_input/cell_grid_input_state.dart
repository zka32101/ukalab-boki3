/// 「表形式のセルを1つずつ選んで数値を入力する」入力画面
/// （`lib/ledger_input/`・`lib/worksheet_input/`）に共通する状態の基底クラス。
///
/// セル位置の型だけが問題ごとに異なる（補助簿は行×列グループ×項目のタプル、
/// 精算表は勘定科目コード×列のタプル）ため、セル参照型 [C] をジェネリクスで
/// 受け取る。具象の状態クラス自身を返す必要がある [copyWithGrid] のために、
/// サブクラス自身の型 [Self] も合わせて受け取る
/// （`class Foo extends CellGridInputState<C, Foo>` という自己参照になる）。
abstract class CellGridInputState<C, Self extends CellGridInputState<C, Self>> {
  const CellGridInputState({
    required this.editableCells,
    this.values = const {},
    this.selectedCell,
  });

  /// 問題ごとの入力可能セル（正解データの blankCells の位置）。
  final List<C> editableCells;

  /// 入力済みのセルの値。
  final Map<C, int> values;

  final C? selectedCell;

  bool isEditable(C cell) => editableCells.contains(cell);

  int? valueAt(C cell) => values[cell];

  /// 具象の状態クラスを保ったまま複製する。
  Self copyWithGrid({
    List<C>? editableCells,
    Map<C, int>? values,
    C? Function()? selectedCell,
  });
}
