import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_core/ukalab_core.dart';

/// 新旧どちらの配点levelでも、`subjectQuestionCounts` が要求する数だけ
/// 科目ごとに問題が揃っているかを確認する（levelIdをnullにして全levelで
/// 共通利用する設計のため、問題データ側で自然に満たされるはずだが、
/// 将来問題を絞り込む変更をしたときの回帰検知として置く）。
void main() {
  test('両levelとも科目別の出題数ぶん問題が揃っている', () {
    final examJson = jsonDecode(
      File('assets/exam/boki3.exam.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final exam = ExamConfig.fromJson(examJson);

    final text = File('assets/exam/boki3.questions.jsonl').readAsStringSync();
    final parsed = parseQuestionsJsonl(text);
    expect(parsed.issues, isEmpty);

    final countBySubject = <String, int>{};
    for (final q in parsed.questions) {
      if (q.disabled) continue;
      countBySubject[q.subjectId] = (countBySubject[q.subjectId] ?? 0) + 1;
    }

    for (final levelId in ['level3_until_2027_03', 'level3_from_2027_04']) {
      final level = exam.level(levelId);
      expect(level, isNotNull, reason: '$levelId が見つかりません');
      final counts = level!.subjectQuestionCounts;
      expect(counts, isNotNull, reason: '$levelId に subjectQuestionCounts がありません');
      counts!.forEach((subjectId, required) {
        final available = countBySubject[subjectId] ?? 0;
        expect(
          available,
          greaterThanOrEqualTo(required),
          reason: '$levelId の $subjectId は$required問必要だが$available問しかない',
        );
      });
    }
  });
}
