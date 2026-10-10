import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_core/ukalab_core.dart';

import 'package:ukalab_boki3/evidence_input/evidence_question_view.dart';
import 'package:ukalab_boki3/journal_input/journal_input_controller.dart';
import 'package:ukalab_boki3/journal_input/journal_input_state.dart';

/// `assets/exam/boki3.questions.jsonl` の boki3-j-0025 と同じ内容。
const _prompt = '出張した従業員から、次の領収書を添えて旅費交通費の精算を受け、現金で支払った。'
    '「新幹線運賃 8,500円」。この取引を仕訳しなさい。';

const _answer = JournalAnswer(
  lines: [
    JournalLine(side: JournalSide.debit, account: 'travel_expense', amount: 8500),
    JournalLine(side: JournalSide.credit, account: 'cash', amount: 8500),
  ],
);

void main() {
  testWidgets('証ひょうが「」で囲まれている問題は、領収書カードと短い指示文を表示する', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: EvidenceQuestionView(prompt: _prompt, correctAnswer: _answer),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 経緯の説明文・証ひょうカードのタイトルと項目・短縮された指示文が表示される。
    expect(find.textContaining('出張した従業員から'), findsOneWidget);
    expect(find.text('領収書'), findsOneWidget);
    expect(find.text('新幹線運賃 8,500円'), findsOneWidget);
    expect(find.text('この取引を仕訳しなさい。'), findsOneWidget);
    // 証ひょうの内容がそのまま仕訳入力テーブルの問題文として重複表示されない。
    expect(find.textContaining('新幹線運賃 8,500円。この取引'), findsNothing);
  });

  testWidgets('カードに表示された内容どおりに仕訳を入力すると正解になる', (tester) async {
    JournalJudgeResult? reported;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: EvidenceQuestionView(
              prompt: _prompt,
              correctAnswer: _answer,
              explanation: '解説テキスト',
              onAnswered: (result, _) => reported = result,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(EvidenceQuestionView));
    final container = ProviderScope.containerOf(element);
    final controller = container.read(journalInputProvider.notifier);

    controller.selectCell(
      const JournalCellRef(rowIndex: 0, side: JournalSide.debit, field: JournalCellField.account),
    );
    controller.setAccount('travel_expense');
    for (final digit in '8500'.split('')) {
      controller.appendDigit(digit);
    }
    controller.selectCell(
      const JournalCellRef(rowIndex: 0, side: JournalSide.credit, field: JournalCellField.account),
    );
    controller.setAccount('cash');
    for (final digit in '8500'.split('')) {
      controller.appendDigit(digit);
    }
    await tester.pumpAndSettle();

    await tester.tap(find.text('答え合わせ'));
    await tester.pumpAndSettle();

    expect(reported, isNotNull);
    expect(reported!.isCorrect, isTrue);
    expect(find.text('正解です'), findsOneWidget);
  });

  testWidgets('「」を含まない問題は通常の仕訳入力（元のprompt全文）にフォールバックする', (tester) async {
    const fallbackPrompt = '得意先から売掛金100,000円の回収として、振込手数料440円が差し引かれた残額が'
        '普通預金口座に入金された旨の振込明細を受け取った。この取引を仕訳しなさい。';
    const fallbackAnswer = JournalAnswer(
      lines: [
        JournalLine(side: JournalSide.debit, account: 'ordinary_deposit', amount: 99560),
        JournalLine(side: JournalSide.debit, account: 'commission_expense', amount: 440),
        JournalLine(side: JournalSide.credit, account: 'accounts_receivable', amount: 100000),
      ],
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: EvidenceQuestionView(prompt: fallbackPrompt, correctAnswer: fallbackAnswer),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('振込明細を受け取った'), findsOneWidget);
    expect(find.text('借方科目'), findsOneWidget);
  });
}
