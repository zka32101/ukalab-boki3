import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ukalab_core/ukalab_core.dart';

import '../exam_data/current_level.dart';
import '../exam_data/exam_data_cache.dart';
import '../practice/practice_page.dart';

/// 「学ぶ」タブに出す、弱点ドリルの入口（premium の機能）。
///
/// 解答履歴から弱い論点を選び、その論点の問題を既存の演習画面（[PracticePage]）で出題する。
/// premium でなければ案内を出すだけで、画面には入らない（[PremiumFeature.weakDrill]）。
class WeakDrillCard extends ConsumerWidget {
  const WeakDrillCard({
    super.key,
    required this.progressStore,
    this.loadQuestionList = loadQuestions,
    this.clock = DateTime.now,
  });

  final ProgressStore progressStore;

  /// 問題の読み込み（テストで差し替える）。
  final Future<List<Question>> Function() loadQuestionList;

  /// 現在時刻の取得元（テストで固定する）。
  final DateTime Function() clock;

  void _toast(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final entitlement = ref.read(entitlementStateProvider).valueOrNull ?? EntitlementState.free;
    if (!canUsePremiumFeature(PremiumFeature.weakDrill, isPremium: entitlement.hasPremium)) {
      _toast(context, '弱点ドリルはプレミアムの機能です。設定から購入できます。');
      return;
    }
    final now = clock();
    final levelId = currentLevelId(now: now);
    final questions = [
      for (final q in await loadQuestionList())
        if (q.levelId == null || q.levelId == levelId) q,
    ];
    final records = await progressStore.loadRecords();
    final drill = buildWeakDrill(questions, records, now: now);
    if (!context.mounted) return;
    if (drill.isEmpty) {
      _toast(context, 'まだ弱点がありません。「学ぶ」で練習すると、苦手な論点が見つかります。');
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PracticePage(
          progressStore: progressStore,
          restrictToQids: {for (final q in drill) q.qid},
          title: '弱点ドリル',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // タップ時に読むだけだと未購読で読み込み中のまま「無料」と判定されるため、ここで購読しておく。
    ref.watch(entitlementStateProvider);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _start(context, ref),
        icon: const Icon(Icons.trending_down),
        label: const Align(
          alignment: Alignment.centerLeft,
          child: Text('弱点ドリル（プレミアム）'),
        ),
      ),
    );
  }
}
