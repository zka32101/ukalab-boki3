import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_boki3/practice/choice_question_view.dart';

void main() {
  testWidgets('解説文に用語集の見出し語が含まれると、タップで用語カードを開けるチップが出る', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ChoiceQuestionView(
            prompt: 'ダミーの設問文',
            choices: ['ア', 'イ'],
            answerIndex: 0,
            explanation: '仕訳は取引を借方と貸方に分けて記録する。',
          ),
        ),
      ),
    );

    // 設問文・選択肢には用語チップを出さない（ヒントになってしまうため）。
    expect(find.byType(ActionChip), findsNothing);

    await tester.tap(find.text('ア').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('答え合わせ'));
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await tester.pumpAndSettle();

    final chip = find.widgetWithText(ActionChip, '仕訳');
    expect(chip, findsOneWidget);

    await tester.tap(chip);
    await tester.pumpAndSettle();

    expect(find.text('関連用語'), findsOneWidget);
  });
}
