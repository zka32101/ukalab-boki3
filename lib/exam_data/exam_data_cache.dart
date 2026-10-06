import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:yourwish_kentei/yourwish_kentei.dart';

Future<List<Question>>? _questionsFuture;
Future<ExamConfig>? _examConfigFuture;

/// `assets/exam/boki3.questions.jsonl` を読み込み・パースする。
///
/// `PracticePage`・`RecordsPage`・`MockExamPage` がそれぞれ独立にこのファイルを
/// 読み込み・パースしていたのをここに集約し、アプリ起動中は結果をキャッシュして
/// タブを行き来するたびに再読み込みしないようにする（問題データは実行中に
/// 変わらない静的アセットのため、キャッシュして問題ない）。
Future<List<Question>> loadQuestions() {
  return _questionsFuture ??= _loadQuestions();
}

Future<List<Question>> _loadQuestions() async {
  final text = await rootBundle.loadString('assets/exam/boki3.questions.jsonl');
  final parsed = parseQuestionsJsonl(text);
  if (parsed.issues.isNotEmpty) {
    throw StateError('問題データの読み込みに失敗しました: ${parsed.issues}');
  }
  return parsed.questions;
}

/// `assets/exam/boki3.exam.json` を読み込む（同様にキャッシュする）。
Future<ExamConfig> loadExamConfig() {
  return _examConfigFuture ??= _loadExamConfig();
}

Future<ExamConfig> _loadExamConfig() async {
  final text = await rootBundle.loadString('assets/exam/boki3.exam.json');
  return ExamConfig.fromJson(jsonDecode(text) as Map<String, dynamic>);
}
