import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_boki3/company_mode/company_mode_history_store.dart';
import 'package:ukalab_boki3/progress/progress_revision.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';
import 'package:ukalab_boki3/records/records_page.dart';

/// 下部タブは `IndexedStack`（`app_common_kit` の `UkalabShell`）で管理されており、
/// 一度ビルドされたタブは破棄・再ビルドされない。そのため、既にマウント済みの
/// `RecordsPage` を一切作り直さずに、[progressRevision] の変化だけで
/// 最新の解答記録を反映できることを確認する。
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('マウントしたままprogressRevisionが変化すると、記録タブが自動で最新化される', (tester) async {
    final progressStore = InMemoryProgressStore();
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

    expect(find.text('復習が必要な問題はありません。'), findsOneWidget);

    // RecordsPage を作り直さず（Navigator操作なし）に、裏側で解答記録が
    // 追加された状況を再現する（practice_page.dart が行うのと同じ手順）。
    await progressStore.addRecord(
      ProgressRecord(qid: 'boki3-c-0001', subjectId: 'q2_choubo', correct: false, at: DateTime.now()),
    );
    progressRevision.value++;

    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    expect(find.text('苦手な1問をまとめて復習する'), findsOneWidget);
    expect(find.text('復習が必要な問題はありません。'), findsNothing);
  });
}
