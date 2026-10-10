import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ukalab_boki3/hands_free/hands_free_choice_question.dart';
import 'package:ukalab_boki3/hands_free/hands_free_state.dart';
import 'package:ukalab_boki3/practice/choice_question_view.dart';

Widget _app({
  void Function(int, bool)? onAnswered,
  VoidCallback? onNext,
}) =>
    MaterialApp(
      home: Scaffold(
        body: HandsFreeChoiceQuestion(
          prompt: '現金を受け取ったときの処理はどれか。',
          choices: const ['現金が増える', '現金が減る', '変化なし'],
          answerIndex: 0,
          explanation: '現金は資産なので、受け取ると増える。',
          onAnswered: onAnswered,
          onNext: onNext,
        ),
      ),
    );

void main() {
  late FakeSpeechBackend speech;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    speech = FakeSpeechBackend();
    appSpeechBackendForTest = speech;
    appHandsFree.value = const HandsFreeSettings();
  });

  tearDown(() {
    appSpeechBackendForTest = null;
    appHandsFree.value = const HandsFreeSettings();
  });

  testWidgets('オフの間は、従来の選択式の画面で、読み上げない', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.byType(ChoiceQuestionView), findsOneWidget);
    expect(find.text('答え合わせ'), findsOneWidget);
    expect(speech.spoken, isEmpty);
  });

  testWidgets('オンなら、問題を自動で読み上げ、大きなボタンで答えられる', (tester) async {
    appHandsFree.value = const HandsFreeSettings(enabled: true);
    int? answered;
    bool? wasCorrect;
    await tester.pumpWidget(_app(
      onAnswered: (i, c) {
        answered = i;
        wasCorrect = c;
      },
      onNext: () {},
    ));
    await tester.pump();

    expect(find.byType(ChoiceQuestionView), findsNothing);
    expect(speech.spoken.first, contains('現金を受け取ったとき'));

    await tester.tap(find.text('現金が減る'));
    await tester.pump();

    expect(answered, 1);
    expect(wasCorrect, isFalse);
    expect(find.text('不正解です'), findsOneWidget);
    expect(find.text('次の問題へ'), findsOneWidget);
    // 解説も読み上げる。
    expect(speech.spoken.any((t) => t.contains('資産')), isTrue);
  });

  testWidgets('正解すると、正解の表示になる', (tester) async {
    appHandsFree.value = const HandsFreeSettings(enabled: true);
    await tester.pumpWidget(_app(onNext: () {}));
    await tester.pump();
    await tester.tap(find.text('現金が増える'));
    await tester.pump();
    expect(find.text('正解です'), findsOneWidget);
  });
}
