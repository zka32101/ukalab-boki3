import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_boki3/mock_exam/mock_exam_page.dart';
import 'package:ukalab_boki3/practice/choice_question_view.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('模擬試験を開始し、全問解答すると結果画面が表示される', (tester) async {
    // 模擬試験画面はロード中の CircularProgressIndicator や、開始後は
    // 制限時間のカウントダウン（Timer.periodic）が動き続けるため、
    // pumpAndSettle ではなく有限の pump を使う。
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: MockExamPage(progressStore: InMemoryProgressStore())),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    for (var i = 0; i < 10 && find.text('模擬試験を開始する').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('模擬試験を開始する'), findsOneWidget);
    await tester.tap(find.text('模擬試験を開始する'));
    await tester.pump();

    // 出題数（20問）ぶん、解答中は正誤を表示せず「次へ」で進む。
    // choice型は選択肢を1つ選ばないと「次へ」が押せない。
    for (var i = 0; i < 20; i++) {
      expect(find.text('次へ'), findsOneWidget, reason: '$i問目で「次へ」が見つからない');
      if (find.byType(ChoiceQuestionView).evaluate().isNotEmpty) {
        await tester.tap(find.byType(InkWell).first);
        await tester.pump();
      }
      await tester.tap(find.text('次へ'));
      await tester.pump();
    }

    // 結果画面：総合得点と合否メッセージが表示される。
    expect(find.textContaining('点'), findsWidgets);
    expect(find.byType(FilledButton), findsWidgets);

    // 「解答結果の詳細を見る」から、全20問ぶんの正誤・解説レビュー画面を開ける。
    await tester.tap(find.text('解答結果の詳細を見る'));
    await tester.pumpAndSettle();

    expect(find.text('解答結果の詳細'), findsOneWidget);
    expect(find.text('1問目'), findsOneWidget);
    expect(find.text('不正解です'), findsWidgets);

    // 一覧の末尾（20問目）までスクロールして表示できることを確認する。
    await tester.scrollUntilVisible(find.text('20問目'), 500, scrollable: find.byType(Scrollable));
    expect(find.text('20問目'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 空欄のまま解答したので全問不正解のはず。「間違えた問題を復習する」から
    // 復習セッション（PracticePage）に入れる。
    final reviewButton = find.textContaining('問を復習する');
    expect(reviewButton, findsOneWidget);
    await tester.tap(reviewButton);
    await tester.pump();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    for (var i = 0; i < 10 && find.byType(CircularProgressIndicator).evaluate().isNotEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump();

    expect(find.text('間違えた問題を復習する'), findsOneWidget);
    expect(find.textContaining('問目'), findsOneWidget);
  });
}
