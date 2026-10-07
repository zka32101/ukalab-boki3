import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ukalab_boki3/startup/legacy_key_migration.dart';

void main() {
  test('旧キーのテーマ設定・ストリークを新キーへ移行する', () async {
    SharedPreferences.setMockInitialValues({
      'ukalab_boki3_theme_mode': 'dark',
      'ukalab_boki3_streak_days': 5,
      'ukalab_boki3_last_study_date': '2026-10-06',
    });
    final prefs = await SharedPreferences.getInstance();

    await migrateLegacyProgressKeys();

    expect(prefs.getString('app_common_kit_theme_mode'), 'dark');
    expect(prefs.getInt('app_common_kit_streak_days'), 5);
    expect(prefs.getString('app_common_kit_last_study_date'), '2026-10-06');
    expect(prefs.containsKey('ukalab_boki3_theme_mode'), isFalse);
    expect(prefs.containsKey('ukalab_boki3_streak_days'), isFalse);
    expect(prefs.containsKey('ukalab_boki3_last_study_date'), isFalse);
  });

  test('新キーに既に値があれば上書きしない', () async {
    SharedPreferences.setMockInitialValues({
      'ukalab_boki3_theme_mode': 'dark',
      'app_common_kit_theme_mode': 'light',
    });
    final prefs = await SharedPreferences.getInstance();

    await migrateLegacyProgressKeys();

    expect(prefs.getString('app_common_kit_theme_mode'), 'light');
  });

  test('旧キーが無ければ何もしない', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await migrateLegacyProgressKeys();

    expect(prefs.getKeys(), isEmpty);
  });

  test('2回呼んでも結果が変わらない（冪等）', () async {
    SharedPreferences.setMockInitialValues({
      'ukalab_boki3_streak_days': 3,
    });
    final prefs = await SharedPreferences.getInstance();

    await migrateLegacyProgressKeys();
    await migrateLegacyProgressKeys();

    expect(prefs.getInt('app_common_kit_streak_days'), 3);
  });
}
