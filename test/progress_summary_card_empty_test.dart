import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';
import 'package:ukalab_boki3/progress/progress_summary_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('記録が無いときは案内文を表示する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: ProgressSummaryCard(store: InMemoryProgressStore()))),
    );
    await tester.pumpAndSettle();

    expect(find.text('演習や模擬試験を解くと、ここに科目別の正答率が表示されます。'), findsOneWidget);
  });
}
