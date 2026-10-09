import 'package:ukalab_core/ukalab_core.dart';

import '../journal_input/account_catalog.dart';

/// 会社経営モードの各ターンの仕訳を積み上げて計算した、勘定科目ごとの残高。
///
/// 財務諸表の集計には勘定科目グループ（資産・負債・純資産・収益・費用）の
/// 判定が要るが、科目マスタ（[boki3Accounts]）はアプリ固有のため、
/// `yourwish_kentei` 側には置かず、このファイル（ukalab-boki3側）に持つ。
class CompanyLedger {
  const CompanyLedger({required this.balances});

  /// 勘定科目コード → 残高。その科目の「増加方向」をプラスとする
  /// （資産・費用は借方残高、負債・純資産・収益は貸方残高）。
  final Map<String, int> balances;

  /// 指定したグループの科目の残高一覧（0円の科目は含まない）。
  List<MapEntry<String, int>> entriesOf(AccountGroup group) => [
        for (final e in balances.entries)
          if (e.value != 0 && _groupOf(e.key) == group) e,
      ];

  int totalOf(AccountGroup group) =>
      entriesOf(group).fold(0, (sum, e) => sum + e.value);

  /// 当期純利益（収益 − 費用）。
  int get netIncome => totalOf(AccountGroup.revenue) - totalOf(AccountGroup.expense);

  /// 資産合計。
  int get totalAssets => totalOf(AccountGroup.asset);

  /// 負債合計。
  int get totalLiabilities => totalOf(AccountGroup.liability);

  /// 純資産合計（元入れ等の資本金・利益剰余金の残高 + 当期純利益）。
  int get totalEquity => totalOf(AccountGroup.equity) + netIncome;

  AccountGroup? _groupOf(String code) =>
      boki3Accounts.where((a) => a.code == code).firstOrNull?.group;
}

extension on Iterable<AccountDef> {
  AccountDef? get firstOrNull => isEmpty ? null : first;
}

/// 複数ターンぶんの仕訳（[JournalLine]）を積み上げて [CompanyLedger] を作る。
CompanyLedger buildCompanyLedger(Iterable<JournalLine> allLines) {
  final debit = <String, int>{};
  final credit = <String, int>{};
  for (final line in allLines) {
    final target = line.side == JournalSide.debit ? debit : credit;
    target[line.account] = (target[line.account] ?? 0) + line.amount;
  }

  final accounts = {...debit.keys, ...credit.keys};
  final balancesByCode = {for (final a in boki3Accounts) a.code: a};
  final balances = <String, int>{};
  for (final code in accounts) {
    final group = balancesByCode[code]?.group;
    final raw = (debit[code] ?? 0) - (credit[code] ?? 0);
    balances[code] = (group == AccountGroup.asset || group == AccountGroup.expense) ? raw : -raw;
  }
  return CompanyLedger(balances: balances);
}
