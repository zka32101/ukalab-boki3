import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_boki3/practice/practice_page.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';

/// 間隔反復（直近の不正解を優先出題する機能）の検証。
void main() {
  testWidgets('直近で不正解だった問題を、通常の練習セッションでも先頭に優先出題する', (tester) async {
    final progressStore = InMemoryProgressStore();
    // boki3-c-0001 を「さっき間違えた」記録として仕込んでおく。
    await progressStore.addRecord(
      ProgressRecord(
        qid: 'boki3-c-0001',
        subjectId: 'q2_choubo',
        correct: false,
        at: DateTime.now().subtract(const Duration(days: 3)),
      ),
    );

    await tester.pumpWidget(MaterialApp(home: PracticePage(progressStore: progressStore)));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    for (var i = 0; i < 10 && find.text('答え合わせ').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 147問中もっとも最近不正解だった boki3-c-0001 が1問目に出題され、
    // 「苦手な問題を復習中」の表示も出る。
    expect(find.text('次のうち、資産に分類される勘定科目はどれか。'), findsOneWidget);
    expect(find.text('苦手な問題を復習中'), findsOneWidget);
  });
}
