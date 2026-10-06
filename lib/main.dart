import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import 'journal_input/journal_question_view.dart';
import 'mock_exam/mock_exam_page.dart';
import 'practice/practice_page.dart';
import 'progress/progress_store.dart';
import 'progress/progress_summary_card.dart';
import 'records/records_page.dart';

/// 演習・模擬試験の解答記録の保存先。端末内保存（アプリ全体で共有）。
final ProgressStore appProgressStore = SharedPreferencesProgressStore();

void main() {
  runApp(const ProviderScope(child: UkalabBoki3App()));
}

class UkalabBoki3App extends StatelessWidget {
  const UkalabBoki3App({super.key});

  static const _field = UkalabField.biz;
  static const _cert = UkalabCert.boki3;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'うかラボ 簿記3級',
      theme: UkalabTheme.light(field: _field, cert: _cert),
      darkTheme: UkalabTheme.dark(field: _field, cert: _cert),
      home: UkalabShell(
        pages: [
          const _HomePage(),
          const _LearnPage(),
          const _MockExamTab(),
          RecordsPage(progressStore: appProgressStore),
          const _AboutPage(),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 24),
        Center(
          child: Text('うかラボ 簿記3級', style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 16),
        ProgressSummaryCard(store: appProgressStore),
      ],
    );
  }
}

/// 「学ぶ」タブ。現時点は仕訳入力UIの動作確認用サンプル問題への入口のみ。
class _LearnPage extends StatelessWidget {
  const _LearnPage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const _SampleJournalQuestionPage()),
            ),
            child: const Text('仕訳の問題を試す（サンプル）'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => PracticePage(progressStore: appProgressStore)),
            ),
            child: const Text('問題を練習する（問題集）'),
          ),
        ],
      ),
    );
  }
}

class _SampleJournalQuestionPage extends StatelessWidget {
  const _SampleJournalQuestionPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('仕訳の問題（サンプル）')),
      body: const SafeArea(
        child: JournalQuestionView(
          prompt: '商品1,000円を現金で売り上げた。この取引を仕訳しなさい。',
          correctAnswer: JournalAnswer(
            lines: [
              JournalLine(side: JournalSide.debit, account: 'cash', amount: 1000),
              JournalLine(side: JournalSide.credit, account: 'sales', amount: 1000),
            ],
          ),
          explanation: '現金(資産)が増えるので借方に、売上(収益)が発生するので貸方に記入する。',
        ),
      ),
    );
  }
}

/// 「模擬」タブ。本試験形式（出題数・制限時間・配点）で1回通しで解く
/// 模擬試験モードへの入口。
class _MockExamTab extends StatelessWidget {
  const _MockExamTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => MockExamPage(progressStore: appProgressStore)),
        ),
        child: const Text('模擬試験を始める'),
      ),
    );
  }
}

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Text(
          'このアプリについて',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12),
        Text(
          '「うかラボ 簿記3級」は、日本商工会議所および各地商工会議所とは一切関係のない、'
          '非公式の学習アプリです。「日商簿記」は各団体の商標・登録商標である可能性があります。',
        ),
      ],
    );
  }
}
