import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import 'package:ukalab_boki3/ledger_input/ledger_input_controller.dart';
import 'package:ukalab_boki3/ledger_input/ledger_question_view.dart';

/// 商品有高帳（移動平均法）サンプルの LedgerAnswer。
/// `assets/exam/boki3.questions.jsonl` の boki3-l-0001 と同じ内容。
const _answer = LedgerAnswer(
  rows: [
    LedgerRowMeta(rowIndex: 0, date: '4/1', description: '前月繰越'),
    LedgerRowMeta(rowIndex: 1, date: '4/5', description: '仕入れ'),
    LedgerRowMeta(rowIndex: 2, date: '4/10', description: '売上げ'),
  ],
  givenCells: [
    LedgerCell(rowIndex: 0, group: LedgerColumnGroup.balance, field: LedgerField.quantity, value: 10),
    LedgerCell(rowIndex: 0, group: LedgerColumnGroup.balance, field: LedgerField.unitPrice, value: 100),
    LedgerCell(rowIndex: 0, group: LedgerColumnGroup.balance, field: LedgerField.amount, value: 1000),
    LedgerCell(rowIndex: 1, group: LedgerColumnGroup.receipt, field: LedgerField.quantity, value: 10),
    LedgerCell(rowIndex: 1, group: LedgerColumnGroup.receipt, field: LedgerField.unitPrice, value: 140),
    LedgerCell(rowIndex: 1, group: LedgerColumnGroup.receipt, field: LedgerField.amount, value: 1400),
  ],
  blankCells: [
    LedgerCell(rowIndex: 1, group: LedgerColumnGroup.balance, field: LedgerField.quantity, value: 20),
    LedgerCell(rowIndex: 1, group: LedgerColumnGroup.balance, field: LedgerField.unitPrice, value: 120),
    LedgerCell(rowIndex: 1, group: LedgerColumnGroup.balance, field: LedgerField.amount, value: 2400),
    LedgerCell(rowIndex: 2, group: LedgerColumnGroup.issue, field: LedgerField.quantity, value: 15),
    LedgerCell(rowIndex: 2, group: LedgerColumnGroup.issue, field: LedgerField.unitPrice, value: 120),
    LedgerCell(rowIndex: 2, group: LedgerColumnGroup.issue, field: LedgerField.amount, value: 1800),
    LedgerCell(rowIndex: 2, group: LedgerColumnGroup.balance, field: LedgerField.quantity, value: 5),
    LedgerCell(rowIndex: 2, group: LedgerColumnGroup.balance, field: LedgerField.unitPrice, value: 120),
    LedgerCell(rowIndex: 2, group: LedgerColumnGroup.balance, field: LedgerField.amount, value: 600),
  ],
);

void main() {
  testWidgets('商品有高帳の全blankCellsに正しい値を入力すると正解になる', (tester) async {
    LedgerJudgeResult? reported;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1200,
              child: LedgerQuestionView(
                prompt: 'テスト問題',
                correctAnswer: _answer,
                explanation: '解説テキスト',
                onAnswered: (result, _) => reported = result,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 未入力セルは空文字表示（編集不可セルの「ー」とは区別される）のため、
    // テキスト検索では狙ったセルを一意に選べない。worksheet_autoscroll_test
    // と同様、ledgerInputProvider を直接操作してセルを選択する。
    final element = tester.element(find.byType(LedgerQuestionView));
    final container = ProviderScope.containerOf(element);

    for (final cell in _answer.blankCells) {
      container
          .read(ledgerInputProvider.notifier)
          .selectCell((cell.rowIndex, cell.group, cell.field));
      await tester.pumpAndSettle();
      for (final digit in cell.value.toString().split('')) {
        await tester.tap(find.text(digit).first);
        await tester.pump();
      }
    }

    await tester.tap(find.text('答え合わせ'));
    await tester.pumpAndSettle();

    expect(reported, isNotNull);
    expect(reported!.isCorrect, isTrue);
    expect(find.text('正解です'), findsOneWidget);
    expect(find.text('解説テキスト'), findsOneWidget);
  });
}
