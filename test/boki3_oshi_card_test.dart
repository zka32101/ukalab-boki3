import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_boki3/oshi/boki3_oshi_card.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

ProgressRecord _r(String qid, bool ok) =>
    ProgressRecord(qid: qid, subjectId: 'q1_shiwake', correct: ok, at: DateTime(2026, 10, 7));

void main() {
  final ids = {for (var i = 0; i < 100; i++) 'q$i'};

  test('記録がなければ Lv1', () {
    expect(oshiStageFromRecords(questionIds: ids, records: const []), MascotStage.lv1);
  });

  test('解いた範囲と正答率が増えるほど段階が上がる（下がらない向きに単調）', () {
    final few = [for (var i = 0; i < 10; i++) _r('q$i', true)];
    final many = [for (var i = 0; i < 100; i++) _r('q$i', true)];
    final a = oshiStageFromRecords(questionIds: ids, records: few).index;
    final b = oshiStageFromRecords(questionIds: ids, records: many).index;
    expect(b, greaterThan(a));
    expect(b, MascotStage.lv5.index);
  });

  test('出題範囲外の記録は数えない', () {
    final out = [for (var i = 0; i < 50; i++) _r('other$i', true)];
    expect(oshiStageFromRecords(questionIds: ids, records: out), MascotStage.lv1);
  });
}
