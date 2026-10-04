# うかラボ 簿記3級

日商簿記検定3級の学習アプリ（非公式）。日本商工会議所・各地商工会議所とは関係ありません。

## 構成と依存

```
ukalab-boki3（このリポジトリ） → yourwish_kentei（検定エンジン） → app_common_kit（共通基盤）
```

このリポジトリは「ExamConfig・問題データ・テーマ・ストア設定」だけを持つ薄いリポジトリとして保つ方針です。
依存は `pubspec.yaml` で `ref: vX.Y.Z` のタグ固定（`main` は参照しない）。

| リポジトリ | タグ |
|---|---|
| `zka32101/app_common_kit` | v0.2.0 |
| `zka32101/yourwish_kentei` | v0.10.0 |

タグ作成（この環境からの `git push --tags` はネットワークプロキシにHTTP 403で拒否される）は、
`yourwish_kentei` リポジトリに追加した `.github/workflows/create-tag.yml`（workflow_dispatch、
手動トリガーのみ）経由で行う。`tag_name`・`target_sha`・`message` を入力して実行すると、
CI上でタグを作成・pushできる。

## 現状（2026-10-04時点）

- `pubspec.yaml`・`assets/exam/boki3.exam.json`（ExamConfig）・最小限の `lib/main.dart` のみ
- 問題データ（JSONL）は `assets/exam/boki3.questions.jsonl` に31問作成済み（第1問相当の仕訳20問、第2問相当の伝票・証ひょう読み取り5問・理論（choice型）5問、第3問相当の精算表（worksheet型）サンプル1問。出典欄 `sourceRef` に根拠の区分表項目を明記。`test/questions_data_test.dart` で出典必須・貸借一致・ExamConfigとの整合性を機械検証）。過去問の転載はしない方針
- 第2問・第3問の出題形式の設計は `docs/question_types_v1_design.md`。精算表・財務諸表の穴埋めは `QuestionType.worksheet`（`yourwish_kentei` v0.10.0、PR#13）として実装・マージ済み
- 簿記3級に必須の「仕訳タイプ（借方・貸方の勘定科目＋金額を入力する表形式）」は `yourwish_kentei`（`QuestionType.journal`・`JournalLine`・`JournalAnswer`・`judgeJournal`）で実装済み。`PracticeSession`（演習セッション）のjournal対応（`answerJournal`）・worksheet対応（`answerWorksheet`）も実装・マージ済み（v0.9.1〜v0.10.0、PR#11・#13）
- `assets/exam/boki3.questions.jsonl` の仕訳（journal型）・理論（choice型）・精算表（worksheet型）問題を `PracticeSession` で連続出題する画面 `lib/practice/practice_page.dart` を実装。精算表入力UIは `lib/worksheet_input/`（表形式・セル選択・テンキー入力・セル単位の正誤表示、`lib/journal_input/` と対になる構成）。「学ぶ」タブの「問題を練習する（問題集）」から開ける。Playwrightで実機確認済み（journal/choice/worksheet混在31問、精算表5セル全入力→正解判定まで確認、console error 0件）
- `yourwish_kentei` v0.4.0では `LevelConfig.subjectQuestionCounts`（科目別の出題数配分）も追加された（別PR）。簿記3級の大問別出題数に使える
- 推し・コイン・衣装・学習体験の「型」は共通仕様（`app_common_kit` v0.2.0）を適用可能だが、簿記固有の学習体験の「型」9部品はまだ `yourwish_kentei` 側に実装されていない
- 仕訳入力UI（表形式テーブル・科目リストボックス・テンキー）の設計は `docs/journal_input_ui_v0.md`。実装はまず `ukalab-boki3` 側（`lib/journal_input/`）で行う方針
- 勘定科目一覧は `docs/accounts_v1_official.md`（確定版 v1。商工会議所の公式出題区分表PDF（2026-07-31最終改定、2027-04-01施行）をユーザーが提供し、照合済み。ただし2026年度中〜2027年3月実施分の旧区分表はまだ一次資料未入手）

## 2027年4月の配点変更

2027年4月1日以降に施行する3級は配点が 45/25/30（従来 45/20/35）に変わるため、`assets/exam/boki3.exam.json` では
`level3_until_2027_03` と `level3_from_2027_04` の2つの level で新旧を切り替える設計にしています。

## 未決・要確認（企画設計書 第6章より）

1. ネット試験の解答入力方式とアプリの入力UIの合わせ方
2. 公式の出題区分表（現行版）の取得と科目一覧への落とし込み
3. 「日商簿記」の表記の可否（商標・誤認）、J-PlatPat・専門家確認
4. 問題の出典（過去問の著作権。自作・自動生成を基本にする）
5. 統一試験・ネット試験の日程
6. 会社経営モードの無料範囲、初回リリースに含めるか
7. 本試験に持ち込める電卓の条件、ネット試験の画面構成
