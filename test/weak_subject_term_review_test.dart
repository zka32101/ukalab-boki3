import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';
import 'package:ukalab_boki3/progress/progress_summary_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('苦手科目（正答率70%未満）のカードから、その科目の用語集を開ける', (tester) async {
    final store = InMemoryProgressStore();
    await store.addRecord(
      ProgressRecord(qid: 'q1', subjectId: 'q1_shiwake', correct: false, at: DateTime(2026, 10, 5)),
    );
    await store.addRecord(
      ProgressRecord(qid: 'q2', subjectId: 'q1_shiwake', correct: true, at: DateTime(2026, 10, 5)),
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ProgressSummaryCard(store: store))),
    );
    await tester.pumpAndSettle();

    expect(find.text('用語集で復習する'), findsOneWidget);

    await tester.tap(find.text('用語集で復習する'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.text('用語集（第1問 仕訳）'), findsOneWidget);
    expect(find.widgetWithText(ListTile, '仕訳'), findsOneWidget);
    // 第3問（決算）の用語は、第1問（仕訳）の絞り込み中は出さない。
    expect(find.widgetWithText(ListTile, '精算表'), findsNothing);
  });
}
