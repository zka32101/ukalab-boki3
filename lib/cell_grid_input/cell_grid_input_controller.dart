import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cell_grid_input_state.dart';

/// [CellGridInputState] を操作するコントローラの基底クラス。セル選択・
/// テンキー入力（桁追加・000・バックスペース・クリア）・次の未入力セルへの
/// 自動フォーカス移動という、表形式セル入力に共通の操作をまとめる。
///
/// サブクラスは [initial] で具象の初期状態を返すだけでよい。
abstract class CellGridInputController<C, S extends CellGridInputState<C, S>>
    extends Notifier<S> {
  /// 値の桁数上限（暫定8桁）。入力ミスの暴走を防ぐ。
  static const maxValue = 99999999;

  /// [editableCells] で初期化した具象の状態を返す。
  S initial(List<C> editableCells);

  @override
  S build() => initial(const []);

  /// 問題の入力可能セルで初期化する。
  void initFor(List<C> editableCells) {
    state = initial(editableCells);
  }

  void selectCell(C cell) {
    if (!state.isEditable(cell)) return;
    state = state.copyWithGrid(selectedCell: () => cell);
  }

  void appendDigit(String digit) => _editValue((current) {
        final next = (current ?? 0) * 10 + int.parse(digit);
        return next > maxValue ? current : next;
      });

  /// `000` キー（3桁一括）。
  void appendTripleZero() => _editValue((current) {
        if (current == null) return null;
        final next = current * 1000;
        return next > maxValue ? current : next;
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
    state = state.copyWithGrid(values: values);
  }

  /// 値の入力を確定し、次の未入力セルへ自動でフォーカスを移す（「次へ」ボタン用）。
  void confirmAmount() {
    final cell = state.selectedCell;
    if (cell == null) return;
    final index = state.editableCells.indexOf(cell);
    for (var i = index + 1; i < state.editableCells.length; i++) {
      final next = state.editableCells[i];
      if (!state.values.containsKey(next)) {
        state = state.copyWithGrid(selectedCell: () => next);
        return;
      }
    }
    state = state.copyWithGrid(selectedCell: () => null);
  }
}
