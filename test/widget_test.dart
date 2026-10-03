import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ukalab_boki3/main.dart';

void main() {
  testWidgets('起動してホーム画面と下部5タブが表示される', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UkalabBoki3App()));
    await tester.pumpAndSettle();

    expect(find.text('うかラボ 簿記3級'), findsOneWidget);
    for (final label in const ['ホーム', '学ぶ', '模擬', '記録', '設定']) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('「学ぶ」タブからサンプル仕訳問題を開ける', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: UkalabBoki3App()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('学ぶ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('仕訳の問題を試す（サンプル）'));
    await tester.pumpAndSettle();

    expect(find.text('借方科目'), findsOneWidget);
    expect(find.text('貸方科目'), findsOneWidget);
    expect(find.text('答え合わせ'), findsOneWidget);
  });
}
