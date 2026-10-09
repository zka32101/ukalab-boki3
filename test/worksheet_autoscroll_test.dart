import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_core/ukalab_core.dart';

import 'package:ukalab_boki3/worksheet_input/worksheet_input_controller.dart';
import 'package:ukalab_boki3/worksheet_input/worksheet_question_view.dart';

/// 画面外（横スクロールした先）にある入力セルを選択したときに、
/// [WorksheetTable] が自動でそのセルまでスクロールすることを確認する。
void main() {
  testWidgets('画面外の入力セルを選択すると横スクロールが自動で追従する', (tester) async {
    const answer = WorksheetAnswer(
      givenCells: [
        WorksheetCell(account: 'equipment', column: WorksheetColumn.trialBalanceDebit, amount: 600000),
        WorksheetCell(
          account: 'accumulated_depreciation',
          column: WorksheetColumn.trialBalanceCredit,
          amount: 200000,
        ),
      ],
      blankCells: [
        WorksheetCell(account: 'depreciation_expense', column: WorksheetColumn.adjustmentDebit, amount: 100000),
        WorksheetCell(
          account: 'accumulated_depreciation',
          column: WorksheetColumn.adjustmentCredit,
          amount: 100000,
        ),
        WorksheetCell(
          account: 'depreciation_expense',
          column: WorksheetColumn.incomeStatementDebit,
          amount: 100000,
        ),
        WorksheetCell(account: 'equipment', column: WorksheetColumn.balanceSheetDebit, amount: 600000),
        WorksheetCell(
          account: 'accumulated_depreciation',
          column: WorksheetColumn.balanceSheetCredit,
          amount: 300000,
        ),
      ],
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 600,
              child: WorksheetQuestionView(prompt: 'テスト問題', correctAnswer: answer),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    double horizontalOffset() {
      for (final element in find.byType(Scrollable).evaluate()) {
        final scrollable = element.widget as Scrollable;
        final isHorizontal =
            scrollable.axisDirection == AxisDirection.left || scrollable.axisDirection == AxisDirection.right;
        if (isHorizontal) {
          final state = (element as StatefulElement).state as ScrollableState;
          return state.position.pixels;
        }
      }
      throw StateError('横方向のScrollableが見つからない');
    }

    expect(horizontalOffset(), 0.0);

    // 幅320pxでは一番右の列（貸借対照表貸方）は画面外にあるはず。
    // 画面外のセルを直接選択し、自動スクロールが効くことを確認する。
    final element = tester.element(find.byType(WorksheetQuestionView));
    final container = ProviderScope.containerOf(element);
    container
        .read(worksheetInputProvider.notifier)
        .selectCell(('accumulated_depreciation', WorksheetColumn.balanceSheetCredit));
    await tester.pumpAndSettle();

    expect(horizontalOffset(), greaterThan(0.0));
  });
}
