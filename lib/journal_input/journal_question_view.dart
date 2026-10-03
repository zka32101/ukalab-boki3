import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import 'balance_indicator.dart';
import 'journal_diff_mapper.dart';
import 'journal_input_controller.dart';
import 'journal_input_state.dart';
import 'journal_input_table.dart';
import 'journal_result_banner.dart';
import 'numeric_keypad.dart';

/// 仕訳問題1問分の画面。問題文・貸借バランス表示・入力テーブル・テンキー・
/// 答え合わせをまとめる。
class JournalQuestionView extends ConsumerStatefulWidget {
  const JournalQuestionView({
    super.key,
    required this.prompt,
    required this.correctAnswer,
    this.explanation,
  });

  final String prompt;
  final JournalAnswer correctAnswer;
  final String? explanation;

  @override
  ConsumerState<JournalQuestionView> createState() => _JournalQuestionViewState();
}

class _JournalQuestionViewState extends ConsumerState<JournalQuestionView> {
  static const _maxRecent = 5;

  final List<String> _recentAccounts = [];
  JournalJudgeResult? _result;

  void _onAccountSelected(String code) {
    setState(() {
      _recentAccounts.remove(code);
      _recentAccounts.insert(0, code);
      if (_recentAccounts.length > _maxRecent) _recentAccounts.removeLast();
    });
  }

  void _checkAnswer() {
    final lines = ref.read(journalInputProvider).toJournalLines();
    setState(() => _result = judgeJournal(widget.correctAnswer, lines));
  }

  void _retry() {
    setState(() => _result = null);
    ref.read(journalInputProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalInputProvider);
    final controller = ref.read(journalInputProvider.notifier);
    final cellDiffs = _result == null ? null : buildCellDiffs(state.rows, _result!.diffs);
    final showKeypad = _result == null && state.selectedCell?.field == JournalCellField.amount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(widget.prompt, style: Theme.of(context).textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BalanceIndicator(debitTotal: state.debitTotal, creditTotal: state.creditTotal),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: JournalInputTable(
              recentAccountCodes: _recentAccounts,
              cellDiffs: cellDiffs,
              readOnly: _result != null,
              onAccountSelected: _onAccountSelected,
            ),
          ),
        ),
        if (_result != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: JournalResultBanner(result: _result!, explanation: widget.explanation),
          ),
        if (showKeypad)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: NumericKeypad(
              onDigit: controller.appendDigit,
              onTripleZero: controller.appendTripleZero,
              onBackspace: controller.backspaceAmount,
              onClear: controller.clearAmount,
              onNext: controller.confirmAmount,
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _result == null
              ? FilledButton(onPressed: _checkAnswer, child: const Text('答え合わせ'))
              : OutlinedButton(onPressed: _retry, child: const Text('もう一度')),
        ),
      ],
    );
  }
}
