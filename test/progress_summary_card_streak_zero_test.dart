import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';
import 'package:ukalab_boki3/progress/progress_summary_card.dart';

void main() {
  testWidgets('連続学習日数が0のときは「今日から始めよう」のストリークバッジが出る', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final store = InMemoryProgressStore();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ProgressSummaryCard(store: store))),
    );
    await tester.pumpAndSettle();

    expect(find.text('今日から始めよう'), findsOneWidget);
  });
}
