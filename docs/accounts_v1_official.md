# 簿記3級 勘定科目一覧（確定版 v1・2027年4月以降の新区分表ベース）

## 出典

- 「商工会議所簿記検定試験出題区分表」（日本商工会議所。1959年9月1日制定、2025年12月25日改定、
  2026年7月31日最終改定、**2027年4月1日施行**）
- 「紙媒体による手形・小切手の廃止および企業会計基準第34号『リースに関する会計基準』等の適用に
  ともなう商工会議所簿記検定試験出題区分表などの改定について【確定版】」（2026年7月31日 日本商工会議所）
- 「簿記検定試験初級　出題範囲・内容」（同日付最終改定。「使用する勘定科目」一覧を実務的な参考として使用）

ユーザーが商工会議所の公式PDFを直接ダウンロードして提供（2026-10-03）。本一覧はこれら一次資料を
Claudeが読み取って作成した。転記ミスの可能性があるため、問題データ作成時は該当箇所を都度この
一覧と突き合わせること。

## 重要な注意（2026年度と2027年度で範囲が異なる）

- **2026年度中（〜2027年3月実施分、ネット試験・統一試験とも）は2022年度適用の旧区分表が
  引き続き適用される。** 旧区分表では手形（受取手形・支払手形）・小切手の振出しが3級の範囲に
  含まれていたと見られるが、**旧区分表（2022年度版）の一次資料は未入手**のため、本一覧には含めない。
  `assets/exam/boki3.exam.json` の `level3_until_2027_03` 向け問題を作る際は別途確認が必要。
- **2027年4月1日以降（`level3_from_2027_04`）は本一覧が確定版として使える。**
- 紙媒体の手形・小切手は全国銀行協会が2026年度末で電子交換所での交換を廃止する方針を受け、
  手形関連の規定は区分表からすべて削除された（小切手も同様。当座預金自体は存続）。
- 今回の改定で3級に新規追加された主な項目: 普通預金（イ．の明記追加）、販売のつど売上原価勘定に
  振り替える方法、有形固定資産の除却・廃棄、定率法による減価償却（簡易な出題にとどめる）。
- リースは3級の出題範囲外（引き続き賃貸借処理＝支払家賃・支払地代で出題）。

## 資産（assets）

| account | 科目名 | 備考 |
|---|---|---|
| cash | 現金 | |
| petty_cash | 小口現金 | |
| checking_deposit | 当座預金 | |
| ordinary_deposit | 普通預金 | 2027年度版で新規明記 |
| time_deposit | 定期預金（その他の預貯金） | |
| accounts_receivable | 売掛金 | |
| credit_accounts_receivable | クレジット売掛金 | キャッシュレス決済を含む |
| electronic_receivable | 電子記録債権 | |
| loan_receivable | 貸付金 | |
| advance_paid | 立替金 | |
| accrued_revenue | 未収入金 | |
| advance_payment | 前払金 | |
| temporary_payment | 仮払金 | |
| gift_certificates_receivable | 受取商品券 | |
| guarantee_deposit | 差入保証金 | ※印（上級由来だが3級で簡易出題の可能性） |
| merchandise_inventory | 繰越商品 | |
| building | 建物 | |
| equipment | 備品 | |
| vehicle | 車両運搬具 | |
| land | 土地 | |
| accumulated_depreciation | 減価償却累計額 | |
| allowance_for_doubtful_accounts | 貸倒引当金 | 資産のマイナス（評価勘定） |
| suspense_paid_consumption_tax | 仮払消費税 | 税抜方式 |

## 負債（liabilities）

| account | 科目名 | 備考 |
|---|---|---|
| accounts_payable | 買掛金 | |
| electronic_payable | 電子記録債務 | |
| borrowings | 借入金 | |
| accrued_payable | 未払金 | |
| advance_received | 前受金 | |
| deposit_received | 預り金 | |
| temporary_receipt | 仮受金 | |
| unpaid_expense | 未払費用 | 決算整理 |
| unpaid_corporate_tax | 未払法人税等 | |
| unpaid_consumption_tax | 未払消費税 | |
| suspense_received_consumption_tax | 仮受消費税 | 税抜方式 |

## 純資産（equity）

| account | 科目名 |
|---|---|
| capital_stock | 資本金 |
| legal_reserve | 利益準備金 |
| retained_earnings | 繰越利益剰余金 |

## 収益（revenue）

| account | 科目名 |
|---|---|
| sales | 売上 |
| rent_income | 受取家賃 |
| land_rent_income | 受取地代 |
| commission_income | 受取手数料 |
| interest_income | 受取利息 |
| gain_on_disposal_of_fixed_assets | 固定資産売却益 |
| bad_debt_recovery | 償却債権取立益 |
| allowance_reversal | 貸倒引当金戻入 |
| miscellaneous_income | 雑益 |

## 費用（expense）

| account | 科目名 | 備考 |
|---|---|---|
| purchases | 仕入 | |
| shipping_expense | 発送費 | |
| salary | 給料 | |
| statutory_welfare_expense | 法定福利費 | |
| advertising_expense | 広告宣伝費 | |
| travel_expense | 旅費交通費 | |
| communication_expense | 通信費 | |
| supplies_expense | 消耗品費 | |
| utilities_expense | 水道光熱費 | |
| rent_expense | 支払家賃 | |
| land_rent_expense | 支払地代 | |
| insurance_expense | 保険料 | |
| repair_expense | 修繕費 | |
| miscellaneous_expense | 雑費 | |
| bad_debt_expense | 貸倒損失 | |
| provision_for_doubtful_accounts | 貸倒引当金繰入 | |
| interest_expense | 支払利息 | |
| commission_expense | 支払手数料 | |
| depreciation_expense | 減価償却費 | |
| loss_on_disposal_of_fixed_assets | 固定資産売却損 | |
| tax_and_dues | 租税公課 | 固定資産税など |
| corporate_tax | 法人税、住民税及び事業税 | |
| miscellaneous_loss | 雑損 | |

## v0からの主な変更点

| 変更 | 内容 |
|---|---|
| 削除 | `notes_receivable`（受取手形）、`notes_payable`（支払手形） — 2027年度版で廃止 |
| 削除 | `consumption_tax`（費用科目としての「消費税」）— 税抜方式では使わず、`suspense_paid_consumption_tax`・`suspense_received_consumption_tax`・`unpaid_consumption_tax` に置き換え |
| 追加 | `ordinary_deposit`（普通預金）、`advance_paid`（立替金）、`gift_certificates_receivable`（受取商品券）、`guarantee_deposit`（差入保証金）、`accrued_payable`（未払金）、`suspense_paid_consumption_tax`（仮払消費税）、`suspense_received_consumption_tax`（仮受消費税） |
| 追加 | `shipping_expense`（発送費）、`statutory_welfare_expense`（法定福利費）、`land_rent_expense`（支払地代）、`repair_expense`（修繕費）、`miscellaneous_expense`（雑費）、`tax_and_dues`（租税公課） |

## 未確認・要対応

1. 2022年度版（旧区分表、〜2027年3月実施分）の一次資料入手と、`level3_until_2027_03` 向け科目一覧の作成
2. 勘定科目コード（account slug）の最終確定（他の会計系アプリ・簿記2級との共用も考慮）
3. 出題区分表の版（lawVersion相当）の記録方法。本アプリでは `sourceRef`/`lawVersion` に
   「商工会議所簿記検定試験出題区分表 2026-07-31最終改定（2027-04-01施行）」のように記録する方針
