import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cell_grid_input/cell_grid_input_controller.dart';
import 'worksheet_input_state.dart';

/// 表埋め（精算表・財務諸表）入力テーブルの状態を管理する。
/// [LedgerInputController]（`lib/ledger_input/`）と共通のロジックは
/// [CellGridInputController] に切り出している。
class WorksheetInputController
    extends CellGridInputController<WorksheetCellRef, WorksheetInputState> {
  @override
  WorksheetInputState initial(List<WorksheetCellRef> editableCells) =>
      WorksheetInputState(editableCells: editableCells);
}

final worksheetInputProvider =
    NotifierProvider<WorksheetInputController, WorksheetInputState>(WorksheetInputController.new);
