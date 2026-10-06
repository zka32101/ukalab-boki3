import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 表示モード（ライト／ダーク／端末設定に従う）。`MaterialApp` がこれを
/// リッスンして `themeMode` に反映するため、値を変えれば即座に全画面へ
/// 反映される（`main.dart` の `appProgressStore` と異なり、`MaterialApp` 自体が
/// リスナーのため `IndexedStack` のマウント保持を気にする必要はない）。
final ValueNotifier<ThemeMode> appThemeMode = ValueNotifier<ThemeMode>(ThemeMode.system);

const _key = 'ukalab_boki3_theme_mode';

/// 起動時に `SharedPreferences` から復元する。`runApp` より前に呼ぶ想定。
Future<void> loadSavedThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_key);
  appThemeMode.value = ThemeMode.values.firstWhere(
    (m) => m.name == saved,
    orElse: () => ThemeMode.system,
  );
}

/// 表示モードを変更し、端末内に保存する（「設定」タブから呼ぶ）。
Future<void> setThemeMode(ThemeMode mode) async {
  appThemeMode.value = mode;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_key, mode.name);
}
