# 簿記3級 勘定科目一覧（下書き v0・要確認）

**注意: この一覧は一次資料（日本商工会議所の公式出題区分表）ではありません。**
複数の簿記学習サイトの情報を集約した仮案です。`yourwish_kentei` 共通基盤ガイドの教訓
（「AIの査読を信用しすぎない」「一次資料（日商simul・商工会議所の公式サンプル問題等）を
使う」）に従い、公式の出題区分表（`kentei.ne.jp`）が確認できたら必ず照合・修正すること。
2027年4月からの新区分表（暫定版。手形・小切手の廃止、新リース会計基準の追加）にも
未対応。

`account` フィールドの値（JournalLine.account）は英語slugの仮案。確定前に変更の可能性あり。

## 資産（assets）

| account | 科目名 |
|---|---|
| cash | 現金 |
| petty_cash | 小口現金 |
| checking_deposit | 当座預金 |
| ordinary_deposit | 普通預金 |
| time_deposit | 定期預金 |
| notes_receivable | 受取手形 |
| accounts_receivable | 売掛金 |
| credit_accounts_receivable | クレジット売掛金 |
| electronic_receivable | 電子記録債権 |
| merchandise_inventory | 繰越商品 |
| advance_payment | 前払金 |
| prepaid_expense | 前払費用 |
| accrued_revenue | 未収入金 |
| accrued_income | 未収収益 |
| loan_receivable | 貸付金 |
| temporary_payment | 仮払金 |
| building | 建物 |
| vehicle | 車両運搬具 |
| equipment | 備品 |
| land | 土地 |
| accumulated_depreciation | 減価償却累計額 |
| allowance_for_doubtful_accounts | 貸倒引当金（資産のマイナス、評価勘定） |

## 負債（liabilities）

| account | 科目名 |
|---|---|
| notes_payable | 支払手形 |
| accounts_payable | 買掛金 |
| electronic_payable | 電子記録債務 |
| advance_received | 前受金 |
| borrowings | 借入金 |
| unpaid_expense | 未払費用 |
| unpaid_corporate_tax | 未払法人税等 |
| unpaid_consumption_tax | 未払消費税 |
| deposit_received | 預り金 |
| temporary_receipt | 仮受金 |
| unearned_revenue | 前受収益 |

## 純資産（equity）

| account | 科目名 |
|---|---|
| capital_stock | 資本金 |
| retained_earnings | 繰越利益剰余金 |
| legal_reserve | 利益準備金 |

## 収益（revenue）

| account | 科目名 |
|---|---|
| sales | 売上 |
| rent_income | 受取家賃 |
| land_rent_income | 受取地代 |
| commission_income | 受取手数料 |
| interest_income | 受取利息 |
| miscellaneous_income | 雑益 |
| allowance_reversal | 貸倒引当金戻入 |
| bad_debt_recovery | 償却債権取立益 |
| gain_on_disposal_of_fixed_assets | 固定資産売却益 |

## 費用（expense）

| account | 科目名 |
|---|---|
| purchases | 仕入 |
| salary | 給料 |
| utilities_expense | 水道光熱費 |
| supplies_expense | 消耗品費 |
| advertising_expense | 広告費 |
| rent_expense | 支払家賃 |
| insurance_expense | 保険料 |
| travel_expense | 旅費交通費 |
| communication_expense | 通信費 |
| depreciation_expense | 減価償却費 |
| bad_debt_expense | 貸倒損失 |
| provision_for_doubtful_accounts | 貸倒引当金繰入 |
| commission_expense | 支払手数料 |
| interest_expense | 支払利息 |
| miscellaneous_loss | 雑損 |
| loss_on_disposal_of_fixed_assets | 固定資産売却損 |
| corporate_tax | 法人税、住民税及び事業税 |
| consumption_tax | 消費税 |

## 未確認・要対応

1. 公式の出題区分表（`kentei.ne.jp`）との照合（科目の抜け漏れ、科目名の正式表記）
2. 2027年4月からの新区分表（暫定版）: 手形・小切手関連科目（`notes_receivable`・
   `notes_payable`等）が縮小される可能性、新リース会計基準に伴う新科目（リース資産・
   リース債務等）の追加可能性
3. 勘定科目コード（account slug）の最終確定（他の会計系アプリ・簿記2級との共用も考慮）
4. 出題区分表の版（lawVersion相当）の記録方法
