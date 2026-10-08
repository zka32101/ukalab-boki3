import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 会社経営モードの1回のプレイ結果（「記録」タブの経営履歴に表示する）。
class CompanyModeResult {
  const CompanyModeResult({
    required this.scenarioId,
    required this.companyName,
    required this.correctCount,
    required this.turnCount,
    required this.netIncome,
    required this.playedAt,
  });

  final String scenarioId;
  final String companyName;
  final int correctCount;
  final int turnCount;

  /// プレイ終了時点の当期純利益（[CompanyLedger.netIncome]）。
  final int netIncome;
  final DateTime playedAt;

  Map<String, dynamic> toJson() => {
        'scenarioId': scenarioId,
        'companyName': companyName,
        'correctCount': correctCount,
        'turnCount': turnCount,
        'netIncome': netIncome,
        'playedAt': playedAt.toIso8601String(),
      };

  /// 壊れた・不正な入力は null を返す（[ProgressRecord.fromJson] と同じ方針）。
  static CompanyModeResult? fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final scenarioId = json['scenarioId'];
    final companyName = json['companyName'];
    final correctCount = json['correctCount'];
    final turnCount = json['turnCount'];
    final netIncome = json['netIncome'];
    final playedAt = DateTime.tryParse('${json['playedAt']}');
    if (scenarioId is! String ||
        companyName is! String ||
        correctCount is! int ||
        turnCount is! int ||
        netIncome is! int ||
        playedAt == null) {
      return null;
    }
    return CompanyModeResult(
      scenarioId: scenarioId,
      companyName: companyName,
      correctCount: correctCount,
      turnCount: turnCount,
      netIncome: netIncome,
      playedAt: playedAt,
    );
  }
}

/// 会社経営モードの結果の保存先。永続化の具体実装はアプリ側が持つ
/// （[ProgressStore] と同じ分担方針）。
abstract class CompanyModeHistoryStore {
  Future<List<CompanyModeResult>> loadResults();
  Future<void> addResult(CompanyModeResult result);
  Future<void> clearResults();
}

/// テスト・プレビュー用のインメモリ実装。
class InMemoryCompanyModeHistoryStore implements CompanyModeHistoryStore {
  final List<CompanyModeResult> _results = [];

  @override
  Future<List<CompanyModeResult>> loadResults() async => List.unmodifiable(_results);

  @override
  Future<void> addResult(CompanyModeResult result) async => _results.add(result);

  @override
  Future<void> clearResults() async => _results.clear();
}

/// 端末内（`SharedPreferences`）への保存。[SharedPreferencesProgressStore] と
/// 同じパターンで、記録が増え続けないよう直近 [maxResults] 件だけを残す。
class SharedPreferencesCompanyModeHistoryStore implements CompanyModeHistoryStore {
  SharedPreferencesCompanyModeHistoryStore({this.maxResults = 200});

  final int maxResults;

  static const _key = 'ukalab_boki3_company_mode_results';

  @override
  Future<List<CompanyModeResult>> loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final text = prefs.getString(_key);
    if (text == null) return [];
    try {
      final list = jsonDecode(text) as List<dynamic>;
      return [
        for (final e in list)
          if (CompanyModeResult.fromJson(e) case final r?) r,
      ];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addResult(CompanyModeResult result) async {
    final results = await loadResults()
      ..add(result);
    final capped =
        results.length > maxResults ? results.sublist(results.length - maxResults) : results;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode([for (final r in capped) r.toJson()]));
  }

  @override
  Future<void> clearResults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
