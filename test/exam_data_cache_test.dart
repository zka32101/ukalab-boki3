import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_boki3/exam_data/exam_data_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadQuestions は2回目以降に同じFutureを返す（キャッシュされる）', () async {
    final first = loadQuestions();
    final second = loadQuestions();

    // 同じ Future インスタンス（＝アセットの再読み込み・再パースをしていない）。
    expect(identical(first, second), isTrue);

    final questions = await first;
    expect(questions, isNotEmpty);
    expect(await second, same(await first));
  });

  test('loadExamConfig は2回目以降に同じFutureを返す（キャッシュされる）', () async {
    final first = loadExamConfig();
    final second = loadExamConfig();

    expect(identical(first, second), isTrue);

    final exam = await first;
    expect(exam.subjects, isNotEmpty);
  });
}
