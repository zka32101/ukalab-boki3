import 'package:ukalab_core/ukalab_core.dart';

import 'company_ledger.dart';

/// 会社経営モード1シナリオぶんの進行管理（[PracticeSession] の最小版に近いが、
/// 「不正解でも正しい仕訳を帳簿に反映して次へ進む」という演習にはない挙動を持つ）。
///
/// 詰んでゲームが止まらないよう、ターンの正誤にかかわらず常に正解仕訳
/// （[CompanyTurn.answer]）を帳簿に積み上げる。不正解の回数は [wrongCount] に
/// 記録するだけで、進行には影響しない。
class CompanyModeSession {
  CompanyModeSession({required this.scenario});

  final CompanyScenario scenario;

  int _index = 0;
  final List<JournalLine> _allLines = [];
  final List<CompanyTurn> _wrongTurns = [];

  int get index => _index;
  int get turnCount => scenario.turns.length;
  int get wrongCount => _wrongTurns.length;

  /// 不正解だったターン（出題順）。結果画面の「間違えたターンを振り返る」に使う。
  List<CompanyTurn> get wrongTurns => List.unmodifiable(_wrongTurns);

  /// 現在のターン。全ターンを終えたら null（結果画面に遷移する合図）。
  CompanyTurn? get current => _index < scenario.turns.length ? scenario.turns[_index] : null;

  bool get isFinished => current == null;

  /// 現在のターンの正誤を記録し、正解仕訳を帳簿に反映して次のターンへ進む。
  void recordAndAdvance({required bool correct}) {
    final turn = current;
    if (turn == null) return;
    if (!correct) _wrongTurns.add(turn);
    _allLines.addAll(turn.answer.lines);
    _index++;
  }

  /// これまでに反映した仕訳から計算した累積の財務諸表データ。
  CompanyLedger get ledger => buildCompanyLedger(_allLines);
}
