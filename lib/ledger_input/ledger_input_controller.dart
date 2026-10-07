import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cell_grid_input/cell_grid_input_controller.dart';
import 'ledger_input_state.dart';

/// 補助簿（商品有高帳・現金出納帳など）入力テーブルの状態を管理する。
/// [WorksheetInputController]（`lib/worksheet_input/`）と共通のロジックは
/// [CellGridInputController] に切り出している。
class LedgerInputController extends CellGridInputController<LedgerCellRef, LedgerInputState> {
  @override
  LedgerInputState initial(List<LedgerCellRef> editableCells) =>
      LedgerInputState(editableCells: editableCells);
}

final ledgerInputProvider =
    NotifierProvider<LedgerInputController, LedgerInputState>(LedgerInputController.new);
