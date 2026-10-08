import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import 'package:ukalab_boki3/company_mode/company_mode_history_store.dart';
import 'package:ukalab_boki3/company_mode/company_scenario_play_page.dart';
import 'package:ukalab_boki3/journal_input/journal_input_controller.dart';
import 'package:ukalab_boki3/journal_input/journal_input_state.dart';

const _scenario = CompanyScenario(
  scenarioId: 's1',
  examId: 'boki3',
  companyName: 'テスト商店',
  industry: '小売業',
  introText: '導入文です。',
  initialCapital: 100000,
  turns: [
    CompanyTurn(
      turnId: 't1',
      eventText: '現金100,000円を元入れした。',
      answer: JournalAnswer(
        lines: [
          JournalLine(side: JournalSide.debit, account: 'cash', amount: 100000),
          JournalLine(side: JournalSide.credit, account: 'capital_stock', amount: 100000),
        ],
      ),
      explanation: '元入れの解説。',
    ),
  ],
  source: QuestionSource.original,
  sourceRef: 'テスト',
  contentVer: '1',
);

void main() {
  testWidgets('不正解でも正解仕訳で進行し、結果画面に「間違えたターンを振り返る」が表示される', (tester) async {
    final historyStore = InMemoryCompanyModeHistoryStore();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: CompanyScenarioPlayPage(scenario: _scenario, historyStore: historyStore),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('経営を始める'));
    await tester.pumpAndSettle();

    // わざと間違った科目で入力する（貸借は合わせるが科目が不正解）。
    final element = tester.element(find.byType(MaterialApp));
    final container = ProviderScope.containerOf(element);
    final controller = container.read(journalInputProvider.notifier);
    controller.selectCell(
      const JournalCellRef(rowIndex: 0, side: JournalSide.debit, field: JournalCellField.account),
    );
    controller.setAccount('equipment');
    controller.selectCell(
      const JournalCellRef(rowIndex: 0, side: JournalSide.debit, field: JournalCellField.amount),
    );
    for (final digit in '100000'.split('')) {
      controller.appendDigit(digit);
    }
    controller.selectCell(
      const JournalCellRef(rowIndex: 0, side: JournalSide.credit, field: JournalCellField.account),
    );
    controller.setAccount('capital_stock');
    controller.selectCell(
      const JournalCellRef(rowIndex: 0, side: JournalSide.credit, field: JournalCellField.amount),
    );
    for (final digit in '100000'.split('')) {
      controller.appendDigit(digit);
    }
    await tester.pumpAndSettle();

    await tester.tap(find.text('答え合わせ'));
    await tester.pumpAndSettle();
    expect(find.text('不正解です'), findsOneWidget);

    await tester.tap(find.text('次の問題へ'));
    await tester.pumpAndSettle();

    // 結果画面: 不正解でも正解仕訳（現金100,000）が帳簿に反映され、振り返りが出る。
    expect(find.textContaining('仕訳の正答: 0 / 1ターン'), findsOneWidget);
    expect(find.text('間違えたターンを振り返る'), findsOneWidget);
    expect(find.textContaining('現金100,000円を元入れした'), findsWidgets);

    final results = await historyStore.loadResults();
    expect(results.single.correctCount, 0);
  });
}
