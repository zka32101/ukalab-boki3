import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';
import 'package:ukalab_boki3/progress/progress_summary_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('記録があると科目名と正答率が表示される', (tester) async {
    final store = InMemoryProgressStore();
    await store.addRecord(
      ProgressRecord(qid: 'q1', subjectId: 'q1_shiwake', correct: true, at: DateTime(2026, 10, 5)),
    );
    await store.addRecord(
      ProgressRecord(qid: 'q2', subjectId: 'q1_shiwake', correct: true, at: DateTime(2026, 10, 5)),
    );

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ProgressSummaryCard(store: store))),
    );
    await tester.pumpAndSettle();

    expect(find.text('第1問 仕訳'), findsOneWidget);
    expect(find.textContaining('100%'), findsOneWidget);
    expect(find.textContaining('2/2問'), findsOneWidget);
  });
}
