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

## Phase 2: 補助簿の記入（先送り）

商品有高帳（先入先出法・移動平均法）、現金出納帳、仕入帳・売上帳など。行が時系列の取引、列が
受入・払出・残高（数量・単価・金額）という構造で、精算表ともまた違う形式。今回は設計を保留し、
Phase 1（精算表）の実装・実機確認を終えてから着手する。

## 実装順序の提案

1. `yourwish_kentei` に `QuestionType.worksheet` を追加（`judgeWorksheet` 含む、PR）
2. `ukalab-boki3` 側に精算表入力UI（表形式、Phase 1の未決事項1を解決してから）
3. 第3問（決算）の問題データ作成
4. 第2問の `journal` 型応用問題（伝票・証ひょう）のデータ作成（コード変更不要なのですぐ着手可能）
5. 第2問の理論（choice型）問題データ作成（コード変更不要）
6. 補助簿（Phase 2）は別途設計してから
