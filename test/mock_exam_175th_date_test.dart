import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_boki3/mock_exam/mock_exam_page.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';

/// 2027年4月の配点改定（45/20/35→45/25/30）の境目を、実際の試験日程で
/// 確認する。第175回（2027-02-28、統一試験）の施行日は2027-04-01より前のため、
/// まだ旧配点で実施される（2026-10-08、Web検索で日程が判明。TACの解説等、
/// 複数の一次資料〈大学の受験案内PDF等〉で確認）。
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('第175回試験日（2027-02-28）はまだ旧配点45/20/35・20問で表示される', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MockExamPage(
            progressStore: InMemoryProgressStore(),
            now: DateTime(2027, 2, 28),
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
