import 'package:shared_preferences/shared_preferences.dart';

/// `theme_mode_store.dart`・`streak_store.dart` を `app_common_kit` 側へ
/// 移した際（v0.10.0）に `SharedPreferences` のキー名が変わったため、
/// 旧キーに保存されていた値を新キーへ一度だけコピーする。
///
/// `main()` で `loadSavedThemeMode()` より前に呼ぶ想定。新キーに既に値が
/// あれば何もしない（二重実行しても安全）。
const _legacyKeyMap = {
  'ukalab_boki3_theme_mode': 'app_common_kit_theme_mode',
  'ukalab_boki3_streak_days': 'app_common_kit_streak_days',
  'ukalab_boki3_last_study_date': 'app_common_kit_last_study_date',
};

Future<void> migrateLegacyProgressKeys() async {
  final prefs = await SharedPreferences.getInstance();
  for (final MapEntry(key: oldKey, value: newKey) in _legacyKeyMap.entries) {
    if (prefs.containsKey(newKey)) continue;
    final oldValue = prefs.get(oldKey);
    switch (oldValue) {
      case final String s:
        await prefs.setString(newKey, s);
      case final int i:
        await prefs.setInt(newKey, i);
    }
    if (oldValue != null) {
      await prefs.remove(oldKey);
    }
  }
}
