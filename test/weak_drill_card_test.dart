import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_boki3/practice/practice_page.dart';
import 'package:ukalab_boki3/purchase/weak_drill_card.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

final _now = DateTime(2026, 11, 20, 12);

Question _q(String qid) => Question(
      qid: qid,
      examId: 'boki3',
      subjectId: 'q1_shiwake',
      topicId: 'ch1',
      prompt: 'p-$qid',
      choices: const ['a', 'b'],
      answerIndex: 0,
      explanation: 'e',
      source: QuestionSource.original,
      sourceRef: '自作',
      contentVer: '1',
    );

Future<ProgressStore> _pump(
  WidgetTester tester, {
  required bool premium,
  List<ProgressRecord> records = const [],
}) async {
  final store = InMemoryProgressStore();
  for (final r in records) {
    await store.addRecord(r);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        entitlementServiceProvider.overrideWithValue(
          FakeEntitlementService(initial: EntitlementState(hasPremium: premium)),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: WeakDrillCard(
            progressStore: store,
            loadQuestionList: () async => [_q('q1'), _q('q2')],
            clock: () => _now,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return store;
}

void main() {
  testWidgets('premiumでなければ、案内を出して画面には入らない', (tester) async {
    await _pump(tester, premium: false);
    await tester.tap(find.textContaining('弱点ドリル'));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('プレミアムの機能'), findsOneWidget);
    expect(find.byType(PracticePage), findsNothing);
  });

  testWidgets('premiumでも弱点が無ければ、案内を出す', (tester) async {
    await _pump(tester, premium: true);
    await tester.tap(find.textContaining('弱点ドリル'));
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('まだ弱点がありません'), findsOneWidget);
    expect(find.byType(PracticePage), findsNothing);
  });

  testWidgets('premiumで間違えた履歴があれば、弱点ドリルの演習画面が開く', (tester) async {
    await _pump(
      tester,
      premium: true,
      records: [ProgressRecord(qid: 'q1', subjectId: 'q1_shiwake', correct: false, at: _now)],
    );
    await tester.tap(find.textContaining('弱点ドリル'));
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(find.byType(PracticePage), findsOneWidget);
  });
}
