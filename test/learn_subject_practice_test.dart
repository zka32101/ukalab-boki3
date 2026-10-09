import 'package:app_common_kit/app_common_kit.dart' show FakeEntitlementService, entitlementServiceProvider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_boki3/main.dart';

void main() {
  // `main.dart` の `appProgressStore` は実機では `SharedPreferences` を使うが、
  // テスト環境ではプラグインの実体がなく `MissingPluginException` になる。
  // 空のモック値を設定しておくと、実際のプラットフォームチャンネルを介さず
  // メモリ上で読み書きできるようになる。
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('「学ぶ」タブから科目別の練習を開ける', (WidgetTester tester) async {
    // 推しは動き続けるので、「動きを減らす」設定にして pumpAndSettle が終わるようにする。
    tester.platformDispatcher.accessibilityFeaturesTestValue = const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(ProviderScope(
        overrides: [entitlementServiceProvider.overrideWithValue(FakeEntitlementService())],
        child: const UkalabBoki3App(),
      ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('学ぶ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('第1問 仕訳'));
    await tester.pump();
    // 問題データ（jsonl、147問超）の読み込みが終わるまでポーリングする。
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 150));
      });
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('借方科目').evaluate().isNotEmpty) break;
    }

    expect(find.text('第1問 仕訳を練習する'), findsOneWidget);
    expect(find.text('借方科目'), findsOneWidget);
    expect(find.text('貸方科目'), findsOneWidget);
    expect(find.text('答え合わせ'), findsOneWidget);
  });
}
