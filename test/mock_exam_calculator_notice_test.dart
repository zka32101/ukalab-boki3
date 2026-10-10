import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_boki3/mock_exam/mock_exam_page.dart';
import 'package:ukalab_boki3/progress/progress_store.dart';

/// 本試験では電卓を実機で持ち込んで使う（アプリ内に電卓機能はない）という
/// 案内を、模擬試験の導入画面に表示する（2026-10-10、README未決事項7対応）。
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('模擬試験の導入画面に電卓についての案内が表示される', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MockExamPage(progressStore: InMemoryProgressStore()),
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    for (var i = 0; i < 10 && find.textContaining('出題数').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.textContaining('電卓を実機で持ち込んで使います'), findsOneWidget);
  });
}
