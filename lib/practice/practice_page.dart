import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yourwish_kentei/yourwish_kentei.dart';

import '../journal_input/journal_question_view.dart';
import 'choice_question_view.dart';

/// `assets/exam/boki3.questions.jsonl` の問題（type: journal・choice）を
/// [PracticeSession] で順に出題する画面。worksheet型はまだ対応していない
/// （UI未実装、プールから除く）。問題データのロード・パース・品質ゲート
/// （出典必須・貸借一致など）は `test/questions_data_test.dart` で
/// 別途検証済みのため、ここではロード失敗のみハンドリングする。
class PracticePage extends StatefulWidget {
  const PracticePage({super.key});

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  late Future<PracticeSession> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _loadSession();
  }

  Future<PracticeSession> _loadSession() async {
    final text = await rootBundle.loadString('assets/exam/boki3.questions.jsonl');
    final parsed = parseQuestionsJsonl(text);
    if (parsed.issues.isNotEmpty) {
      throw StateError('問題データの読み込みに失敗しました: ${parsed.issues}');
    }
    final supported = parsed.questions.where(
      (q) => q.type == QuestionType.journal || q.type == QuestionType.choice,
    );
    return PracticeSession(pool: supported, size: supported.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('問題を練習する')),
      body: SafeArea(
        child: FutureBuilder<PracticeSession>(
          future: _sessionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('読み込みに失敗しました: ${snapshot.error}'));
            }
            return _SessionBody(session: snapshot.data!);
          },
        ),
      ),
    );
  }
}

class _SessionBody extends StatefulWidget {
  const _SessionBody({required this.session});

  final PracticeSession session;

  @override
  State<_SessionBody> createState() => _SessionBodyState();
}

class _SessionBodyState extends State<_SessionBody> {
  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final current = session.current;
    if (current == null) {
      return _ResultView(session: session);
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${session.index + 1} / ${session.questions.length}問目',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
        Expanded(child: _buildQuestion(current, session)),
      ],
    );
  }

  Widget _buildQuestion(Question current, PracticeSession session) {
    switch (current.type) {
      case QuestionType.journal:
        return JournalQuestionView(
          key: ValueKey(current.qid),
          prompt: current.prompt,
          correctAnswer: current.journalAnswer!,
          explanation: current.explanation,
          onAnswered: (result, lines) => session.answerJournal(lines),
          onNext: () => setState(() {}),
        );
      case QuestionType.choice:
        return ChoiceQuestionView(
          key: ValueKey(current.qid),
          prompt: current.prompt,
          choices: current.choices,
          answerIndex: current.answerIndex,
          explanation: current.explanation,
          onAnswered: (selectedIndex, correct) => session.answer(selectedIndex),
          onNext: () => setState(() {}),
        );
      case QuestionType.worksheet:
        // worksheet型のUIは未実装。_loadSession でプールから除外しているため
        // 通常は到達しない。
        return const Center(child: Text('この問題形式はまだ対応していません'));
    }
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.session});

  final PracticeSession session;

  @override
  Widget build(BuildContext context) {
    final total = session.questions.length;
    final correct = session.correctCount;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('終了しました', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text('正解 $correct / $total問', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('戻る'),
          ),
        ],
      ),
    );
  }
}
