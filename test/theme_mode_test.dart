import 'package:app_common_kit/app_common_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

import 'package:ukalab_boki3/settings/settings_page.dart';

/// 表示モードの永続化ロジック自体（setThemeMode/loadSavedThemeMode）は
/// `app_common_kit` 側でテスト済み。ここでは「設定」タブの実際の操作で
/// `MaterialApp` の `themeMode` が切り替わることだけを確認する。
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appThemeMode.value = ThemeMode.system;
  });

  testWidgets('設定タブでダークを選ぶとMaterialAppのthemeModeが切り替わる', (tester) async {
    await tester.pumpWidget(
      ValueListenableBuilder<ThemeMode>(
        valueListenable: appThemeMode,
        builder: (context, mode, _) => MaterialApp(
          themeMode: mode,
          home: Scaffold(
            body: SettingsPage(progressStore: InMemoryProgressStore()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byWidgetPredicate((w) => w is MaterialApp && w.themeMode == ThemeMode.system), findsOneWidget);

    await tester.tap(find.text('ダーク'));
    await tester.pumpAndSettle();

    expect(find.byWidgetPredicate((w) => w is MaterialApp && w.themeMode == ThemeMode.dark), findsOneWidget);
  });
}
