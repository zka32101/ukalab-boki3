import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_core/ukalab_core.dart';

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
    CompanyTurn(
      turnId: 't2',
      eventText: '商品を40,000円で販売し、現金を受け取った。',
      answer: JournalAnswer(
        lines: [
          JournalLine(side: JournalSide.debit, account: 'cash', amount: 40000),
          JournalLine(side: JournalSide.credit, account: 'sales', amount: 40000),
        ],
      ),
      explanation: '売上の解説。',
    ),
  ],
  source: QuestionSource.original,
  sourceRef: 'テスト',
  contentVer: '1',
);

void main() {
  testWidgets('シナリオを最後まで正しく仕訳すると、結果画面に貸借対照表・損益計算書が表示され、履歴に記録される', (tester) async {
    final historyStore = InMemoryCompanyModeHistoryStore();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: CompanyScenarioPlayPage(scenario: _scenario, historyStore: historyStore),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 導入画面
    expect(find.text('テスト商店'), findsWidgets);
    expect(find.text('導入文です。'), findsOneWidget);
    await tester.tap(find.text('経営を始める'));
    await tester.pumpAndSettle();

    // ターン1: 元入れ（現金100,000 / 資本金100,000）
    expect(find.textContaining('元入れした'), findsOneWidget);
    await _enterJournal(tester, [
      (JournalSide.debit, 'cash', 100000),
      (JournalSide.credit, 'capital_stock', 100000),
    ]);
    await tester.tap(find.text('答え合わせ'));
    await tester.pumpAndSettle();
    expect(find.text('正解です'), findsOneWidget);
    await tester.tap(find.text('次の問題へ'));
    await tester.pumpAndSettle();

    // ターン2: 売上（現金40,000 / 売上40,000）
    expect(find.textContaining('販売し'), findsOneWidget);
    await _enterJournal(tester, [
      (JournalSide.debit, 'cash', 40000),
      (JournalSide.credit, 'sales', 40000),
    ]);
    await tester.tap(find.text('答え合わせ'));
    await tester.pumpAndSettle();
    expect(find.text('正解です'), findsOneWidget);
    await tester.tap(find.text('次の問題へ'));
    await tester.pumpAndSettle();

    // 結果画面
    expect(find.text('貸借対照表（期末時点）'), findsOneWidget);
    expect(find.text('損益計算書'), findsOneWidget);
    expect(find.textContaining('仕訳の正答: 2 / 2ターン'), findsOneWidget);
    expect(find.textContaining('当期純利益'), findsOneWidget);
    // 全問正解のため「間違えたターンを振り返る」は出ない。
    expect(find.text('間違えたターンを振り返る'), findsNothing);

    // プレイ結果が履歴ストアに保存される。
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    final results = await historyStore.loadResults();
    expect(results, hasLength(1));
    expect(results.single.companyName, 'テスト商店');
    expect(results.single.correctCount, 2);
    expect(results.single.turnCount, 2);
    expect(results.single.netIncome, 40000);
  });
}

Future<void> _enterJournal(
  WidgetTester tester,
  List<(JournalSide, String, int)> lines,
) async {
  final element = tester.element(find.byType(MaterialApp));
  final container = ProviderScope.containerOf(element);
  final controller = container.read(journalInputProvider.notifier);

  for (var i = 0; i < lines.length; i++) {
    final (side, account, amount) = lines[i];
    controller.selectCell(JournalCellRef(rowIndex: 0, side: side, field: JournalCellField.account));
    controller.setAccount(account);
    controller.selectCell(JournalCellRef(rowIndex: 0, side: side, field: JournalCellField.amount));
    for (final digit in '$amount'.split('')) {
      controller.appendDigit(digit);
    }
  }
  await tester.pumpAndSettle();
}
