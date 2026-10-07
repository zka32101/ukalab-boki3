import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_boki3/mock_exam/mock_exam_page.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';

/// 2027年4月の配点改定の施行日当日。`test/mock_exam_174th_date_test.dart`・
/// `test/mock_exam_scoring_cutover_before_test.dart` とセットで境界を確認する。
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('施行日当日（2027-04-01）から新配点45/25/30に切り替わる', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MockExamPage(
            progressStore: InMemoryProgressStore(),
            now: DateTime(2027, 4, 1),
          ),
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    for (var i = 0; i < 10 && find.textContaining('出題数').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.textContaining('配点45/25/30'), findsOneWidget);
    expect(find.text('出題数: 20問'), findsOneWidget);
  });
}
