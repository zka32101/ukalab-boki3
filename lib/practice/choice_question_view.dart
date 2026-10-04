import 'package:flutter/material.dart';

/// 選択式（type: choice）問題1問分の画面。問題文・選択肢・答え合わせをまとめる。
/// [JournalQuestionView]（lib/journal_input/）と並ぶ、第2問の理論問題向けの
/// シンプルな選択式UI。
class ChoiceQuestionView extends StatefulWidget {
  const ChoiceQuestionView({
    super.key,
    required this.prompt,
    required this.choices,
    required this.answerIndex,
    this.explanation,
    this.onAnswered,
    this.onNext,
  });

  final String prompt;
  final List<String> choices;
  final int answerIndex;
  final String? explanation;

  /// 答え合わせボタンが押されたときに、選んだ選択肢と正誤を通知する。
  final void Function(int selectedIndex, bool correct)? onAnswered;

  /// 非null なら、答え合わせ後に「もう一度」の代わりに「次の問題へ」ボタンを表示し、
  /// 押されたときにこれを呼ぶ（複数問を連続して出題する画面向け）。
  final VoidCallback? onNext;

  @override
  State<ChoiceQuestionView> createState() => _ChoiceQuestionViewState();
}

class _ChoiceQuestionViewState extends State<ChoiceQuestionView> {
  int? _selected;
  bool _answered = false;

  void _checkAnswer() {
    final selected = _selected;
    if (selected == null) return;
    final correct = selected == widget.answerIndex;
    setState(() => _answered = true);
    widget.onAnswered?.call(selected, correct);
  }

  void _retry() {
    setState(() {
      _answered = false;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final correct = _selected == widget.answerIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(widget.prompt, style: theme.textTheme.titleMedium),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (var i = 0; i < widget.choices.length; i++)
                _ChoiceTile(
                  label: widget.choices[i],
                  selected: _selected == i,
                  correctChoice: _answered && i == widget.answerIndex,
                  wrongChoice: _answered && _selected == i && i != widget.answerIndex,
                  onTap: _answered ? null : () => setState(() => _selected = i),
                ),
            ],
          ),
        ),
        if (_answered)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _ChoiceResultBanner(correct: correct, explanation: widget.explanation),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: !_answered
              ? FilledButton(
                  onPressed: _selected == null ? null : _checkAnswer,
                  child: const Text('答え合わせ'),
                )
              : (widget.onNext != null
                  ? FilledButton(onPressed: widget.onNext, child: const Text('次の問題へ'))
                  : OutlinedButton(onPressed: _retry, child: const Text('もう一度'))),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.correctChoice,
    required this.wrongChoice,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool correctChoice;
  final bool wrongChoice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color? borderColor;
    if (correctChoice) {
      borderColor = theme.colorScheme.primary;
    } else if (wrongChoice) {
      borderColor = theme.colorScheme.error;
    } else if (selected) {
      borderColor = theme.colorScheme.outline;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ?? theme.colorScheme.outlineVariant,
              width: selected || correctChoice || wrongChoice ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              if (correctChoice)
                Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20)
              else if (wrongChoice)
                Icon(Icons.cancel, color: theme.colorScheme.error, size: 20)
              else
                Icon(
                  selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
                  size: 20,
                ),
              const SizedBox(width: 12),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceResultBanner extends StatelessWidget {
  const _ChoiceResultBanner({required this.correct, this.explanation});

  final bool correct;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = correct ? theme.colorScheme.primary : theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(correct ? Icons.check_circle : Icons.cancel, color: color),
              const SizedBox(width: 8),
              Text(
                correct ? '正解です' : '不正解です',
                style: theme.textTheme.titleMedium?.copyWith(color: color),
              ),
            ],
          ),
          if (explanation != null && explanation!.isNotEmpty) ...[
            const Divider(),
            Text(explanation!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
