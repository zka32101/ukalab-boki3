import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yourwish_kentei/yourwish_kentei.dart';

import '../journal_input/journal_question_view.dart';
import '../ledger_input/ledger_question_view.dart';
import '../progress/progress_store.dart';
import '../worksheet_input/worksheet_question_view.dart';
import 'choice_question_view.dart';

/// `assets/exam/boki3.questions.jsonl` の問題（type: journal・choice・worksheet）を
/// [PracticeSession] で順に出題する画面。問題データのロード・パース・品質ゲート
/// （出典必須・貸借一致など）は `test/questions_data_test.dart` で
/// 別途検証済みのため、ここではロード失敗のみハンドリングする。
class PracticePage extends StatefulWidget {
  const PracticePage({super.key, required this.progressStore, this.restrictToQids});

  /// 解答記録の保存先（ホーム画面の科目別正答率に反映される）。
  final ProgressStore progressStore;

  /// 非null なら、全問題の中からこの qid 集合に含まれる問題だけを出題する
  /// （「間違えた問題を復習する」から開くとき用）。
  final Set<String>? restrictToQids;

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
    final restrict = widget.restrictToQids;
    final pool = restrict == null
        ? parsed.questions
        : parsed.questions.where((q) => restrict.contains(q.qid)).toList();
    return PracticeSession(pool: pool, size: pool.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.restrictToQids == null ? '問題を練習する' : '間違えた問題を復習する')),
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
            return _SessionBody(session: snapshot.data!, progressStore: widget.progressStore);
          },
        ),
      ),
    );
  }
}

class _SessionBody extends StatefulWidget {
  const _SessionBody({required this.session, required this.progressStore});

  final PracticeSession session;
  final ProgressStore progressStore;

  @override
  State<_SessionBody> createState() => _SessionBodyState();
}

class _SessionBodyState extends State<_SessionBody> {
  void _recordProgress(String qid, String subjectId, {required bool correct}) {
    unawaited(
      widget.progressStore.addRecord(
        ProgressRecord(qid: qid, subjectId: subjectId, correct: correct, at: DateTime.now()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final current = session.current;
    if (current == null) {
      return _ResultView(session: session, progressStore: widget.progressStore);
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
          onAnswered: (result, lines) {
            session.answerJournal(lines);
            _recordProgress(current.qid, current.subjectId, correct: result.isCorrect);
          },
          onNext: () => setState(() {}),
        );
      case QuestionType.choice:
        return ChoiceQuestionView(
          key: ValueKey(current.qid),
          prompt: current.prompt,
          choices: current.choices,
          answerIndex: current.answerIndex,
          explanation: current.explanation,
          onAnswered: (selectedIndex, correct) {
            session.answer(selectedIndex);
            _recordProgress(current.qid, current.subjectId, correct: correct);
          },
          onNext: () => setState(() {}),
        );
      case QuestionType.worksheet:
        return WorksheetQuestionView(
          key: ValueKey(current.qid),
          prompt: current.prompt,
          correctAnswer: current.worksheetAnswer!,
          explanation: current.explanation,
          onAnswered: (result, cells) {
            session.answerWorksheet(cells);
            _recordProgress(current.qid, current.subjectId, correct: result.isCorrect);
          },
          onNext: () => setState(() {}),
        );
      case QuestionType.ledger:
        return LedgerQuestionView(
          key: ValueKey(current.qid),
          prompt: current.prompt,
          correctAnswer: current.ledgerAnswer!,
          explanation: current.explanation,
          onAnswered: (result, cells) {
            session.answerLedger(cells);
            _recordProgress(current.qid, current.subjectId, correct: result.isCorrect);
          },
          onNext: () => setState(() {}),
        );
    }
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.session, required this.progressStore});

  final PracticeSession session;
  final ProgressStore progressStore;

  @override
  Widget build(BuildContext context) {
    final total = session.questions.length;
    final correct = session.correctCount;
    final wrongQids = {
      for (final r in session.records)
        if (!r.correct) r.qid,
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('終了しました', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text('正解 $correct / $total問', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          if (wrongQids.isNotEmpty)
            FilledButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => PracticePage(progressStore: progressStore, restrictToQids: wrongQids),
                ),
              ),
              child: Text('間違えた${wrongQids.length}問を復習する'),
            ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('戻る'),
          ),
        ],
      ),
    );
  }
}
