import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_boki3/practice/practice_page.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';

/// 「間違えた問題を復習する」機能の検証。choice型2問（うち1問をわざと
/// 不正解にする）を解き、結果画面から復習セッションに入れることを確認する。
void main() {
  testWidgets('間違えた問題だけを復習セッションで出題できる', (tester) async {
    final progressStore = InMemoryProgressStore();
    await tester.pumpWidget(
      MaterialApp(
        home: PracticePage(
          progressStore: progressStore,
          restrictToQids: const {'boki3-c-0001', 'boki3-c-0002'},
        ),
      ),
    );
    // rootBundle.loadString のロード待ち。
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    for (var i = 0; i < 10 && find.text('答え合わせ').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('答え合わせ'), findsOneWidget);

    // 1問目（boki3-c-0001: 答えは「売掛金」=index2）をわざと不正解にする。
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('答え合わせ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('次の問題へ'));
    await tester.pumpAndSettle();

    // 2問目（boki3-c-0002: 答えは「買掛金」=index2）は正解を選ぶ。
    final tiles = find.byType(InkWell);
    await tester.tap(tiles.at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('答え合わせ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('次の問題へ'));
    await tester.pumpAndSettle();

    // 結果画面：1問だけ間違えているので復習ボタンが出る。
    expect(find.text('正解 1 / 2問'), findsOneWidget);
    expect(find.text('間違えた1問を復習する'), findsOneWidget);

    await tester.tap(find.text('間違えた1問を復習する'));
    await tester.pump();
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
