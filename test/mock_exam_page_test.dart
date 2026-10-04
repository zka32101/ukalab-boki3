import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_boki3/mock_exam/mock_exam_page.dart';
import 'package:ukalab_boki3/practice/choice_question_view.dart';

void main() {
  testWidgets('模擬試験を開始し、全問解答すると結果画面が表示される', (tester) async {
    // 模擬試験画面はロード中の CircularProgressIndicator や、開始後は
    // 制限時間のカウントダウン（Timer.periodic）が動き続けるため、
    // pumpAndSettle ではなく有限の pump を使う。
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: MockExamPage())),
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

    // 出題数（15問）ぶん、解答中は正誤を表示せず「次へ」で進む。
    // choice型は選択肢を1つ選ばないと「次へ」が押せない。
    for (var i = 0; i < 15; i++) {
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
  });
}
