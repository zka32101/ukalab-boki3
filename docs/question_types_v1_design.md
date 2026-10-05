# 第2問・第3問の出題形式 設計（v1・ドラフト）

## 出典

企画設計書 `ukalab_簿記3級_企画設計書_v0_1.md`（3-1「問題の形式」）に基づく。

> - 仕訳: 借方・貸方の勘定科目を選び、金額を入力する入力式（対応済み）
> - 帳簿・伝票: 補助簿の選択、伝票の記入（穴埋め）、証ひょうの読み取り
> - 決算: 精算表・試算表・財務諸表の穴埋め（段階入力）
> - 理論（選択式）: 用語・分類の補助的な問題

## 結論（内訳ごとの対応方針）

出題形式を分解すると、新しい `QuestionType` が必要なのは「精算表・財務諸表の穴埋め」と
「補助簿の記入」だけで、残りは既存の `choice`・`journal` 型の応用で対応できる。

| 大問 | 内訳 | 対応方針 | 新設計の要否 |
|---|---|---|---|
| 第2問 | 理論（用語・分類） | 既存の `choice` 型 | 不要 |
| 第2問 | 伝票の記入（入金・出金・振替伝票） | 既存の `journal` 型の応用（1伝票＝1〜2行の仕訳として扱う。入金伝票は貸方に相手科目のみ入力、出金伝票は借方に相手科目のみ入力、振替伝票は通常の仕訳と同じ） | 不要（`topicId` で伝票種別を分類） |
| 第2問 | 証ひょうの読み取り | `journal` 型の応用（証ひょうの内容を `prompt` の文章で表現。画像添付は後続課題） | 不要（当面はテキストのみ） |
| 第2問 | 補助簿の記入（商品有高帳・仕入帳・売上帳など） | 新しい `QuestionType`（行×列の表に数値を記入し、受入・払出・残高などを計算させる） | **要（Phase 2、先送り）** |
| 第3問 | 決算整理仕訳 | 既存の `journal` 型 | 不要 |
| 第3問 | 精算表・財務諸表の穴埋め | 新しい `QuestionType.worksheet`（セル単位の空欄埋め） | **要（Phase 1）** |

## Phase 1: `QuestionType.worksheet`（精算表・財務諸表の穴埋め）

### データモデル案（yourwish_kentei 側に追加）

```dart
/// 精算表・財務諸表の列。
enum WorksheetColumn {
  trialBalanceDebit, trialBalanceCredit,       // 残高試算表
  adjustmentDebit, adjustmentCredit,            // 修正記入
  incomeStatementDebit, incomeStatementCredit,  // 損益計算書
  balanceSheetDebit, balanceSheetCredit,        // 貸借対照表
}

/// 1セル（勘定科目 × 列）の金額。
class WorksheetCell {
  final String account;         // 勘定科目コード
  final WorksheetColumn column;
  final int amount;
}

/// 精算表問題の正解。
class WorksheetAnswer {
  /// 最初から埋まっているセル（残高試算表など、問題文で与える値）。
  final List<WorksheetCell> givenCells;
  /// ユーザーが埋めるべき正解セル。
  final List<WorksheetCell> blankCells;
}
```

### 採点方針

`judgeJournal` と同じ考え方で `judgeWorksheet(WorksheetAnswer, List<WorksheetCell> userInput)` を作り、
セル単位（勘定科目×列の組み合わせ）で正誤を判定する。仕訳と違って貸借の対応付けは不要（セルの位置が
一意に決まる）ため、`journal_judge.dart` より単純になる見込み。部分点（埋まったセル数 / 全セル数）も
ここで計算できるようにする。

### 未決事項

1. 財務諸表（貸借対照表・損益計算書）の穴埋めは、精算表と列構成が異なる（勘定科目の表示名も「売上」
   → 損益計算書では「売上高」になる等）。同じ `WorksheetColumn` で表現しきれるか要検討
   （損益計算書・貸借対照表専用の列挙値を分けるか、あるいは精算表の派生として扱うか）
2. UI側（`lib/journal_input/journal_input_table.dart` 相当）は列数が多く（最大8列）、スマホ画面での
   表示方法を別途検討する必要がある（横スクロール、列の折りたたみなど）

## Phase 2: 補助簿の記入（設計）

対象は商品有高帳（先入先出法・移動平均法）、現金出納帳、当座預金出納帳、売掛金元帳（得意先元帳）、
買掛金元帳（仕入先元帳）、仕入帳・売上帳など。いずれも「行＝時系列の取引、列＝受入／払出／残高
（＋数量・単価・金額）」という共通構造を持つ帳簿で、勘定科目×列という2次元の `worksheet` 型とは
別の形（行×列グループ×項目という3次元）になる。

### 対象の絞り込み方針

補助簿は帳簿ごとに列構成が異なる（商品有高帳は数量・単価・金額の3項目、現金出納帳は金額のみ）が、
「行＝取引、列グループ＝受入／払出／残高、項目＝数量・単価・金額（使わない項目は省略可）」という
共通モデルで表現できる。数量・単価を使わない帳簿（現金出納帳・当座預金出納帳・売掛金元帳・買掛金
元帳）は金額（`amount`）のみのセルで表現し、商品有高帳は3項目をすべて使う形にする。

**先入先出法 vs 移動平均法**: 先入先出法は、仕入のたびに単価の異なるロットが残高欄に並存し、1つの
取引が複数の記入行にまたがることがある（例: 残高に「10個@100円」「20個@120円」の2行が並ぶ）。
移動平均法は残高が常に単一の平均単価になるため、1取引＝1記入行で完結しモデルが単純になる。本設計は
まず移動平均法、または「仕入れた分を使い切ってから次の仕入をする」単純化シナリオの先入先出法
（残高が常に単一ロットになる）を対象にする。複数ロットが並存する一般の先入先出法は、1取引が複数
記入行を持てるようにする拡張が必要なため、**Phase 2.5として先送り**する。

### データモデル案（yourwish_kentei 側に追加）

```dart
/// 補助簿の列グループ。
enum LedgerColumnGroup { receipt, issue, balance }

/// 補助簿の項目。数量・単価を使わない帳簿（現金出納帳など）は amount のみ使う。
enum LedgerField { quantity, unitPrice, amount }

/// 1セル（行 × 列グループ × 項目）の値。
class LedgerCell {
  final int rowIndex;           // 何行目か（0始まり）
  final LedgerColumnGroup group;
  final LedgerField field;
  final int value;
}

/// 1記入行の固定情報（日付・摘要）。同一取引が複数行にまたがる場合、
/// 2行目以降は date/description を空文字にする（実際の帳簿の見た目を踏襲）。
class LedgerRowMeta {
  final int rowIndex;
  final String date;         // 例: "4/1"
  final String description;  // 例: "仕入れ"
}

/// 補助簿問題の正解。
class LedgerAnswer {
  final List<LedgerRowMeta> rows;
  /// 最初から埋まっているセル（前月繰越など、問題文で与える値）。
  final List<LedgerCell> givenCells;
  /// ユーザーが埋めるべき正解セル。
  final List<LedgerCell> blankCells;
}
```

`WorksheetCell` の `account × column` に対して `LedgerCell` は `rowIndex × group × field` が
セルの一意な位置になる点以外は、`WorksheetAnswer`（givenCells/blankCells に分ける設計）と
同じパターンを踏襲する。

### 採点方針

`judgeWorksheet` と同じ考え方で `judgeLedger(LedgerAnswer, List<LedgerCell> userInput)` を作る。
セル単位（`rowIndex × group × field`）で正誤判定（correct/wrongAmount/missing/extra）し、
`WorksheetJudgeResult` と同形の `LedgerJudgeResult` を返す。

### UI設計の方向性

`WorksheetTable`（`lib/worksheet_input/`）と同様、横スクロール可能な `Table` ＋ セル選択＋テンキー
入力の構成を踏襲する。列数は「受入・払出・残高」×「数量・単価・金額」で最大9列になりうるが、
現金出納帳など金額のみの帳簿では3列（収入・支出・残高）まで減る。`WorksheetColumn` を実際に使う
列だけ表示したのと同様、`LedgerColumnGroup × LedgerField` の組み合わせのうち実際に使うものだけを
列として表示する。

同一取引が複数記入行にまたがるケース（前述のPhase 2.5）では、`LedgerRowMeta.date`/`description` が
空文字の行はヘッダー列（日付・摘要）を空欄表示する想定。

### 未決事項

1. 商品有高帳の「摘要」欄の表記（「前月繰越」「仕入れ」「売上げ」等）をどこまで自由記述にするか、
   あるいは固定の選択肢にするか（自由記述は採点対象にしない前提で、`LedgerRowMeta` は常に固定表示）
2. 部分点の扱い（`WorksheetJudgeResult` 同様、埋まったセル数 / 全セル数で計算する想定）
3. 複数ロットが並存する一般の先入先出法（Phase 2.5）に対応する場合の行モデルの拡張方法

## 実装順序の提案

1. `yourwish_kentei` に `QuestionType.worksheet` を追加（`judgeWorksheet` 含む、PR） — 完了
2. `ukalab-boki3` 側に精算表入力UI（表形式） — 完了
3. 第3問（決算）の問題データ作成 — 完了
4. 第2問の `journal` 型応用問題（伝票・証ひょう）のデータ作成 — 完了
5. 第2問の理論（choice型）問題データ作成 — 完了
6. `yourwish_kentei` に `QuestionType.ledger` を追加（`judgeLedger` 含む、Phase 2設計に基づく） — 完了（v0.12.0）
7. `ukalab-boki3` 側に補助簿入力UI（`LedgerTable`、`WorksheetTable` と同パターン） — 完了（`lib/ledger_input/`）
8. 商品有高帳（移動平均法）・現金出納帳などの問題データ作成 — 商品有高帳（移動平均法）1問作成済み。
   現金出納帳など他の補助簿、問題数の拡充は今後の課題
