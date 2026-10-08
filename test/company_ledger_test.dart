import 'package:flutter_test/flutter_test.dart';
import 'package:ukalab_boki3/company_mode/company_ledger.dart';
import 'package:yourwish_kentei/yourwish_kentei.dart';

void main() {
  test('元入れ→仕入（掛け）→売上（現金）を積み上げると、各科目の残高が正しく計算される', () {
    final ledger = buildCompanyLedger([
      // 元入れ: 現金500,000 / 資本金500,000
      const JournalLine(side: JournalSide.debit, account: 'cash', amount: 500000),
      const JournalLine(side: JournalSide.credit, account: 'capital_stock', amount: 500000),
      // 仕入（掛け）: 仕入30,000 / 買掛金30,000
      const JournalLine(side: JournalSide.debit, account: 'purchases', amount: 30000),
      const JournalLine(side: JournalSide.credit, account: 'accounts_payable', amount: 30000),
      // 売上（現金）: 現金80,000 / 売上80,000
      const JournalLine(side: JournalSide.debit, account: 'cash', amount: 80000),
      const JournalLine(side: JournalSide.credit, account: 'sales', amount: 80000),
    ]);

    expect(ledger.balances['cash'], 580000); // 500,000 + 80,000
    expect(ledger.balances['capital_stock'], 500000);
    expect(ledger.balances['accounts_payable'], 30000);
    expect(ledger.balances['purchases'], 30000);
    expect(ledger.balances['sales'], 80000);

    expect(ledger.totalAssets, 580000);
    expect(ledger.totalLiabilities, 30000);
    expect(ledger.netIncome, 50000); // 売上80,000 - 仕入30,000
    expect(ledger.totalEquity, 550000); // 資本金500,000 + 当期純利益50,000

    // 貸借が一致する（資産 = 負債 + 純資産）
    expect(ledger.totalAssets, ledger.totalLiabilities + ledger.totalEquity);
  });

  test('仕訳が1件もなければ残高は空', () {
    final ledger = buildCompanyLedger(const []);
    expect(ledger.balances, isEmpty);
    expect(ledger.totalAssets, 0);
    expect(ledger.netIncome, 0);
  });
}
