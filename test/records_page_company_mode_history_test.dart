import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_boki3/company_mode/company_mode_history_store.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';
import 'package:ukalab_boki3/records/records_page.dart';

void main() {
  testWidgets('会社経営モードのプレイ履歴があると「記録」タブに表示される', (tester) async {
    final historyStore = InMemoryCompanyModeHistoryStore();
    await historyStore.addResult(
      CompanyModeResult(
        scenarioId: 'cafe_donguri',
        companyName: 'カフェどんぐり',
        correctCount: 5,
        turnCount: 6,
        netIncome: 50000,
        playedAt: DateTime.now(),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RecordsPage(
          progressStore: InMemoryProgressStore(),
          companyModeHistoryStore: historyStore,
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.text('経営履歴'), findsOneWidget);
    expect(find.text('カフェどんぐり'), findsOneWidget);
    expect(find.textContaining('仕訳の正答: 5 / 6ターン'), findsOneWidget);
    expect(find.text('+50000円'), findsOneWidget);
  });
}
