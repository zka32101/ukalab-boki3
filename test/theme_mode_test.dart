import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_boki3/progress/progress_store.dart';
import 'package:ukalab_boki3/settings/settings_page.dart';
import 'package:ukalab_boki3/settings/theme_mode_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    appThemeMode.value = ThemeMode.system;
  });

  test('setThemeMode は通知の値を更新し、SharedPreferencesに保存する', () async {
    await setThemeMode(ThemeMode.dark);
    expect(appThemeMode.value, ThemeMode.dark);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('ukalab_boki3_theme_mode'), 'dark');
  });

  test('loadSavedThemeMode は保存済みの値を復元する', () async {
    SharedPreferences.setMockInitialValues({'ukalab_boki3_theme_mode': 'light'});
    await loadSavedThemeMode();
    expect(appThemeMode.value, ThemeMode.light);
  });

  test('保存値が無い・壊れている場合は system にフォールバックする', () async {
    SharedPreferences.setMockInitialValues({'ukalab_boki3_theme_mode': 'invalid'});
    await loadSavedThemeMode();
    expect(appThemeMode.value, ThemeMode.system);
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
