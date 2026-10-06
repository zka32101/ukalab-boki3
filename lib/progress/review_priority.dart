import 'progress_store.dart';

/// 間隔反復の優先qidを計算する。各qidの最新の解答記録（`at` が最大のもの）が
/// 不正解だった問題を「復習が必要」とみなし、不正解のまま最も長く放置されている
/// （`at` が古い）ものから順に並べる。直近で正解し直した問題は対象から外れる。
///
/// `yourwish_kentei` の `PracticeSession(priorityQids: ...)` にそのまま渡す想定。
List<String> reviewPriorityQids(List<ProgressRecord> records) {
  final latestByQid = <String, ProgressRecord>{};
  for (final r in records) {
    final existing = latestByQid[r.qid];
    if (existing == null || r.at.isAfter(existing.at)) {
      latestByQid[r.qid] = r;
    }
  }
  final due = latestByQid.values.where((r) => !r.correct).toList()
    ..sort((a, b) => a.at.compareTo(b.at));
  return [for (final r in due) r.qid];
}
