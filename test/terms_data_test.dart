import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

/// 用語データ（JSONL）の機械検証。出典必須・関連用語のリンク切れなどを確認する。
void main() {
  test('boki3.terms.jsonl が品質ゲートを通る', () {
    final examJson = jsonDecode(
      File('assets/exam/boki3.exam.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final exam = ExamConfig.fromJson(examJson);

    final questionsText = File('assets/exam/boki3.questions.jsonl').readAsStringSync();
    final parsedQuestions = parseQuestionsJsonl(questionsText);
    expect(parsedQuestions.issues, isEmpty);

    final termsText = File('assets/exam/boki3.terms.jsonl').readAsStringSync();
    final parsed = parseTermsJsonl(termsText);
    expect(parsed.issues, isEmpty, reason: '${parsed.issues}');

    final issues = validateTerms(parsed.terms, exam: exam, questions: parsedQuestions.questions);
    expect(issues, isEmpty, reason: '$issues');

    expect(parsed.terms, isNotEmpty);
  });

  test('termId に重複がない', () {
    final text = File('assets/exam/boki3.terms.jsonl').readAsStringSync();
    final parsed = parseTermsJsonl(text);
    final ids = [for (final t in parsed.terms) t.termId];
    expect(ids.toSet().length, ids.length);
  });
}
