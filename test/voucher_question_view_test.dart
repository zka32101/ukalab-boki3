import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import 'package:ukalab_boki3/voucher_input/voucher_input_controller.dart';
import 'package:ukalab_boki3/voucher_input/voucher_kind.dart';
import 'package:ukalab_boki3/voucher_input/voucher_question_view.dart';

/// 出金伝票サンプル（`assets/exam/boki3.questions.jsonl` の boki3-j-0021 と同じ内容）。
/// 「文房具代3,000円を現金で支払い、出金伝票を起票した」
/// → 借方: 消耗品費3,000円、貸方: 現金3,000円。出金伝票では現金側（貸方）は
/// 伝票の種類から自明なため、相手科目（消耗品費）と金額だけを入力させる。
const _paymentAnswer = JournalAnswer(
  lines: [
    JournalLine(side: JournalSide.debit, account: 'supplies_expense', amount: 3000),
    JournalLine(side: JournalSide.credit, account: 'cash', amount: 3000),
  ],
);

/// 入金伝票サンプル（boki3-j-0022 と同じ内容）。
/// 「売掛金5,000円を現金で回収し、入金伝票を起票した」
/// → 借方: 現金5,000円、貸方: 売掛金5,000円。
const _receiptAnswer = JournalAnswer(
  lines: [
    JournalLine(side: JournalSide.debit, account: 'cash', amount: 5000),
    JournalLine(side: JournalSide.credit, account: 'accounts_receivable', amount: 5000),
  ],
);

Future<JournalJudgeResult?> _solveAndAnswer(
  WidgetTester tester, {
  required JournalAnswer answer,
  required VoucherKind kind,
  required String account,
  required int amount,
}) async {
  JournalJudgeResult? reported;
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: VoucherQuestionView(
            prompt: 'テスト問題',
            correctAnswer: answer,
            kind: kind,
            explanation: '解説テキスト',
            onAnswered: (result, _) => reported = result,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // 相手科目の選択はボトムシート経由だが、ledger_question_view_test と同様に
  // voucherInputProvider を直接操作して確定させる（UI操作の再現は別途カバー）。
  final element = tester.element(find.byType(VoucherQuestionView));
  final container = ProviderScope.containerOf(element);
  container.read(voucherInputProvider.notifier).setAccount(account);
  await tester.pumpAndSettle();
  for (final digit in amount.toString().split('')) {
    await tester.tap(find.text(digit).first);
    await tester.pump();
  }

  await tester.tap(find.text('答え合わせ'));
  await tester.pumpAndSettle();
  return reported;
}

void main() {
  testWidgets('出金伝票: 相手科目と金額を正しく入力すると正解になる', (tester) async {
    final reported = await _solveAndAnswer(
      tester,
      answer: _paymentAnswer,
      kind: VoucherKind.payment,
      account: 'supplies_expense',
      amount: 3000,
    );

    expect(reported, isNotNull);
    expect(reported!.isCorrect, isTrue);
    expect(find.text('正解です'), findsOneWidget);
    expect(find.text('解説テキスト'), findsOneWidget);
    expect(find.text('出金伝票'), findsOneWidget);
  });

  testWidgets('入金伝票: 相手科目と金額を正しく入力すると正解になる', (tester) async {
    final reported = await _solveAndAnswer(
      tester,
      answer: _receiptAnswer,
      kind: VoucherKind.receipt,
      account: 'accounts_receivable',
      amount: 5000,
    );

    expect(reported, isNotNull);
    expect(reported!.isCorrect, isTrue);
    expect(find.text('正解です'), findsOneWidget);
    expect(find.text('入金伝票'), findsOneWidget);
  });

  testWidgets('出金伝票: 金額を間違えると不正解になる', (tester) async {
    final reported = await _solveAndAnswer(
      tester,
      answer: _paymentAnswer,
      kind: VoucherKind.payment,
      account: 'supplies_expense',
      amount: 9999,
    );

    expect(reported, isNotNull);
    expect(reported!.isCorrect, isFalse);
    expect(find.text('不正解です'), findsOneWidget);
  });

  testWidgets('振替伝票: 通常の仕訳入力テーブルが伝票の枠付きで表示される', (tester) async {
    const transferAnswer = JournalAnswer(
      lines: [
        JournalLine(side: JournalSide.debit, account: 'purchases', amount: 8000),
        JournalLine(side: JournalSide.credit, account: 'accounts_payable', amount: 8000),
      ],
    );

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: VoucherQuestionView(
              prompt: 'テスト問題',
              correctAnswer: transferAnswer,
              kind: VoucherKind.transfer,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 振替伝票は現金の受け払いを伴わないため、通常の仕訳入力テーブル
    // （借方科目・貸方科目の表形式）をそのまま伝票の枠に入れて表示する。
    expect(find.text('振替伝票'), findsOneWidget);
    expect(find.text('借方科目'), findsOneWidget);
    expect(find.text('貸方科目'), findsOneWidget);
    expect(find.text('答え合わせ'), findsOneWidget);
  });
}
