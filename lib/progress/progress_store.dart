import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 1問分の解答記録（演習・模擬試験どちらの解答でも共通で使う）。
class ProgressRecord {
  const ProgressRecord({
    required this.qid,
    required this.subjectId,
    required this.correct,
    required this.at,
  });

  final String qid;
  final String subjectId;
  final bool correct;
  final DateTime at;

  Map<String, dynamic> toJson() => {
        'qid': qid,
        'subjectId': subjectId,
        'correct': correct,
        'at': at.toIso8601String(),
      };

  static ProgressRecord? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final qid = json['qid'];
    final subjectId = json['subjectId'];
    final correct = json['correct'];
    final at = DateTime.tryParse('${json['at']}');
    if (qid is! String || subjectId is! String || correct is! bool || at == null) {
      return null;
    }
    return ProgressRecord(qid: qid, subjectId: subjectId, correct: correct, at: at);
  }
}

/// 解答記録の保存先。
abstract class ProgressStore {
  Future<List<ProgressRecord>> loadRecords();
  Future<void> addRecord(ProgressRecord record);
}

/// 端末内（`SharedPreferences`）への保存。記録が増え続けないよう、
/// 直近 [maxRecords] 件だけを残す。
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
}

/// テスト・プレビュー用のインメモリ実装。
class InMemoryProgressStore implements ProgressStore {
  final List<ProgressRecord> _records = [];

  @override
  Future<List<ProgressRecord>> loadRecords() async => List.unmodifiable(_records);

  @override
  Future<void> addRecord(ProgressRecord record) async => _records.add(record);
}
