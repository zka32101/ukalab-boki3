import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_boki3/company_mode/company_mode_history_store.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';
import 'package:ukalab_boki3/records/records_page.dart';

void main() {
  testWidgets('不正解の記録があると復習待ちの問題として一覧に出て、まとめて復習できる', (tester) async {
    final progressStore = InMemoryProgressStore();
    await progressStore.addRecord(
      ProgressRecord(
        qid: 'boki3-c-0001',
        subjectId: 'q2_choubo',
        correct: false,
        at: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RecordsPage(
          progressStore: progressStore,
          companyModeHistoryStore: InMemoryCompanyModeHistoryStore(),
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.text('苦手な1問をまとめて復習する'), findsOneWidget);
    expect(find.text('次のうち、資産に分類される勘定科目はどれか。'), findsOneWidget);

    await tester.tap(find.text('苦手な1問をまとめて復習する'));
    await tester.pump();
    // PracticePage（復習セッション）はローディング表示に CircularProgressIndicator
    // を使うため（IndexedStack配下ではなく単発pushのみなので問題ない）、ここだけ
    // 従来どおり消えるまで待つ。
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    for (var i = 0; i < 10 && find.byType(CircularProgressIndicator).evaluate().isNotEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();

    expect(find.text('間違えた問題を復習する'), findsOneWidget);
    expect(find.text('1 / 1問目'), findsOneWidget);
  });
}
