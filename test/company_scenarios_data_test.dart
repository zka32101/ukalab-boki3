import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

/// 会社経営モードのシナリオデータ（JSONL）の機械検証。
void main() {
  test('boki3.company_scenarios.jsonl が品質ゲートを通る', () {
    final examJson = jsonDecode(
      File('assets/exam/boki3.exam.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final exam = ExamConfig.fromJson(examJson);

    final text = File('assets/exam/boki3.company_scenarios.jsonl').readAsStringSync();
    final parsed = parseCompanyScenariosJsonl(text);
    expect(parsed.issues, isEmpty, reason: '${parsed.issues}');

    final issues = validateCompanyScenarios(parsed.scenarios, exam: exam);
    expect(issues, isEmpty, reason: '$issues');

    expect(parsed.scenarios, hasLength(5));
  });

  test('scenarioId に重複がない', () {
    final text = File('assets/exam/boki3.company_scenarios.jsonl').readAsStringSync();
    final parsed = parseCompanyScenariosJsonl(text);
    final ids = [for (final s in parsed.scenarios) s.scenarioId];
    expect(ids.toSet().length, ids.length);
  });
}
