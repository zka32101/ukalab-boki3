import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';
import 'package:ukalab_boki3/progress/progress_summary_card.dart';
import 'package:ukalab_boki3/progress/streak_store.dart';

void main() {
  testWidgets('連続学習日数が1日以上あるとストリーク表示が出る', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await recordStudyToday(now: DateTime(2026, 10, 6));

    final store = InMemoryProgressStore();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ProgressSummaryCard(store: store))),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('日連続で学習中'), findsOneWidget);
  });

  testWidgets('連続学習日数が0のときはストリーク表示が出ない', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final store = InMemoryProgressStore();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ProgressSummaryCard(store: store))),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('日連続で学習中'), findsNothing);
  });
}
