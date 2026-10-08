import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_boki3/company_mode/company_mode_history_store.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';
import 'package:ukalab_boki3/records/records_page.dart';

void main() {
  testWidgets('解答記録が無ければ「復習が必要な問題はありません」と表示する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RecordsPage(
          progressStore: InMemoryProgressStore(),
          companyModeHistoryStore: InMemoryCompanyModeHistoryStore(),
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.text('記録'), findsOneWidget);
    expect(find.text('復習待ちの問題'), findsOneWidget);
    expect(find.text('復習が必要な問題はありません。'), findsOneWidget);
  });
}
