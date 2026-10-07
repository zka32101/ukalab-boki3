import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

export 'package:yourwish_kentei/yourwish_kentei.dart'
    show ProgressRecord, ProgressStore, InMemoryProgressStore;

/// 端末内（`SharedPreferences`）への保存。記録が増え続けないよう、
/// 直近 [maxRecords] 件だけを残す。[ProgressRecord]・[ProgressStore] の
/// 定義自体は `yourwish_kentei`（純Dart）にあり、永続化の具体実装だけを
/// ここに持つ（`shared_preferences` はFlutterプラグインのため）。
class SharedPreferencesProgressStore implements ProgressStore {
  SharedPreferencesProgressStore({this.maxRecords = 2000});

  final int maxRecords;

  static const _key = 'ukalab_boki3_progress_records';

  @override
  Future<List<ProgressRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(_key);
    if (text == null) return [];
    try {
      final list = jsonDecode(text) as List<dynamic>;
      return [
        for (final e in list)
          if (ProgressRecord.fromJson(e) case final r?) r,
      ];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addRecord(ProgressRecord record) async {
    final records = await loadRecords()
      ..add(record);
    final capped =
        records.length > maxRecords ? records.sublist(records.length - maxRecords) : records;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode([for (final r in capped) r.toJson()]));
  }

  @override
  Future<void> clearRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
