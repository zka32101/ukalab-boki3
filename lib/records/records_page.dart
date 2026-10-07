import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import '../exam_data/exam_data_cache.dart';
import '../practice/practice_page.dart';
import '../progress/progress_revision.dart';
import '../progress/progress_summary_card.dart';

/// 「記録」タブ。科目別正答率（ホーム画面と同じカード）に加えて、間隔反復で
/// 復習待ちになっている問題の一覧と、まとめて復習セッションを開くボタンを表示する。
class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key, required this.progressStore});

  final ProgressStore progressStore;

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  late Future<_RecordsData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _load();
    // 下部タブは `IndexedStack` で一度マウントされると破棄されないため、
    // 他のタブで新しい解答記録が追加されても自動では再読み込みされない。
    // `progressRevision` の変化を見て、このタブを離れていても明示的に読み直す。
    progressRevision.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    progressRevision.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onProgressChanged() {
    setState(() {
      _dataFuture = _load();
    });
  }

  Future<_RecordsData> _load() async {
    final exam = await loadExamConfig();
    final questions = await loadQuestions();
    final byQid = {for (final q in questions) q.qid: q};
    final subjectNameOf = {for (final s in exam.subjects) s.subjectId: s.name};

    final records = await widget.progressStore.loadRecords();
    final reviewQuestions = [
      for (final qid in reviewPriorityQids(records))
        if (byQid[qid] case final q?) q,
    ];

    return _RecordsData(reviewQuestions: reviewQuestions, subjectNameOf: subjectNameOf);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_RecordsData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // 下部タブは `IndexedStack` で起動時に全タブを即座にビルドするため、
          // ここで常時アニメーションする `CircularProgressIndicator` を出すと
          // `pumpAndSettle` が終わらなくなる（[ProgressSummaryCard] と同じ理由）。
          return const SizedBox.shrink();
        }
        if (snapshot.hasError) {
          return ErrorState(message: '読み込みに失敗しました: ${snapshot.error}');
        }
        final data = snapshot.data!;
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SizedBox(height: 24),
            Center(child: Text('記録', style: Theme.of(context).textTheme.titleLarge)),
            const SizedBox(height: 16),
            ProgressSummaryCard(store: widget.progressStore),
            _ReviewSection(
              questions: data.reviewQuestions,
              subjectNameOf: data.subjectNameOf,
              progressStore: widget.progressStore,
            ),
          ],
        );
      },
    );
  }
}

class _RecordsData {
  const _RecordsData({required this.reviewQuestions, required this.subjectNameOf});

  final List<Question> reviewQuestions;
  final Map<String, String> subjectNameOf;
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({
    required this.questions,
    required this.subjectNameOf,
    required this.progressStore,
  });

  final List<Question> questions;
  final Map<String, String> subjectNameOf;
  final ProgressStore progressStore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('復習待ちの問題', style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              '直近で不正解のまま放置されている問題です。「問題を練習する」でも自動的に優先出題されます。',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 12),
            if (questions.isEmpty)
              const EmptyState(message: '復習が必要な問題はありません。', icon: Icons.check_circle_outline)
            else ...[
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PracticePage(
                      progressStore: progressStore,
                      restrictToQids: {for (final q in questions) q.qid},
                    ),
                  ),
                ),
                icon: const Icon(Icons.replay),
                label: Text('苦手な${questions.length}問をまとめて復習する'),
              ),
              const SizedBox(height: 12),
              for (final q in questions) _ReviewTile(question: q, subjectNameOf: subjectNameOf),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.question, required this.subjectNameOf});

  final Question question;
  final Map<String, String> subjectNameOf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subjectNameOf[question.subjectId] ?? question.subjectId,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary),
          ),
          Text(
            question.prompt,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
