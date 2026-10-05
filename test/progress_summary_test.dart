import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';
import 'package:ukalab_boki3/progress/progress_summary.dart';

void main() {
  test('科目ごとに正答数・解答数・正答率を集計する', () {
    final now = DateTime(2026, 10, 5);
    final records = [
      ProgressRecord(qid: 'q1', subjectId: 'q1_shiwake', correct: true, at: now),
      ProgressRecord(qid: 'q2', subjectId: 'q1_shiwake', correct: false, at: now),
      ProgressRecord(qid: 'q3', subjectId: 'q1_shiwake', correct: true, at: now),
      ProgressRecord(qid: 'q4', subjectId: 'q3_kessan', correct: false, at: now),
    ];

    final summary = summarizeBySubject(records);

    expect(summary['q1_shiwake']!.correct, 2);
    expect(summary['q1_shiwake']!.total, 3);
    expect(summary['q1_shiwake']!.pct, closeTo(66.67, 0.01));
    expect(summary['q3_kessan']!.correct, 0);
    expect(summary['q3_kessan']!.total, 1);
    expect(summary['q3_kessan']!.pct, 0);
    expect(summary.containsKey('q2_choubo'), isFalse);
  });

  test('記録が0件なら空のMapを返す', () {
    expect(summarizeBySubject(const []), isEmpty);
  });

  test('InMemoryProgressStore は追加した記録をそのまま読み出せる', () async {
    final store = InMemoryProgressStore();
    final record = ProgressRecord(
      qid: 'boki3-j-0001',
      subjectId: 'q1_shiwake',
      correct: true,
      at: DateTime(2026, 10, 5),
    );
    await store.addRecord(record);

    final loaded = await store.loadRecords();
    expect(loaded, hasLength(1));
    expect(loaded.first.qid, 'boki3-j-0001');
    expect(loaded.first.correct, isTrue);
  });

  test('ProgressRecord は JSON との相互変換ができる', () {
    final record = ProgressRecord(
      qid: 'boki3-c-0001',
      subjectId: 'q2_choubo',
      correct: false,
      at: DateTime(2026, 10, 5, 12, 30),
    );
    final restored = ProgressRecord.fromJson(record.toJson())!;
    expect(restored.qid, record.qid);
    expect(restored.subjectId, record.subjectId);
    expect(restored.correct, record.correct);
    expect(restored.at, record.at);
  });

  test('不正な形式のJSONはnullを返す', () {
    expect(ProgressRecord.fromJson('not a map'), isNull);
    expect(ProgressRecord.fromJson({'qid': 'q1'}), isNull);
  });
}
