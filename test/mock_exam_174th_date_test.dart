import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_boki3/mock_exam/mock_exam_page.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';

/// 2027年4月の配点改定（45/20/35→45/25/30）の境目を、実際の試験日程で
/// 確認する。第174回（2026-11-15、統一試験）は旧配点での実施が確定している。
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('第174回試験日（2026-11-15）は旧配点45/20/35・20問で表示される', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MockExamPage(
            progressStore: InMemoryProgressStore(),
            now: DateTime(2026, 11, 15),
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

    expect(find.textContaining('配点45/20/35'), findsOneWidget);
    expect(find.text('出題数: 20問'), findsOneWidget);
  });
}
