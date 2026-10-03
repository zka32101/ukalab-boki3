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
| `zka32101/yourwish_kentei` | v0.4.0 |

## 現状（2026-10-03時点）

- `pubspec.yaml`・`assets/exam/boki3.exam.json`（ExamConfig）・最小限の `lib/main.dart` のみ
- 問題データ（JSONL）は未着手。一次資料（日商simul・商工会議所の公式サンプル問題等）を使い、出典欄（`sourceRef`・`lawVersion`）を必ず付ける方針（AIの査読を信用しすぎない）
- 簿記3級に必須の「仕訳タイプ（借方・貸方の勘定科目＋金額を入力する表形式）」は `yourwish_kentei` v0.4.0（`QuestionType.journal`・`JournalLine`・`JournalAnswer`・`judgeJournal`）で実装済み。既存のchoice型アプリへの影響なし。`PracticeSession`（演習セッション）のjournal対応はまだ未実装
- `yourwish_kentei` v0.4.0では `LevelConfig.subjectQuestionCounts`（科目別の出題数配分）も追加された（別PR）。簿記3級の大問別出題数に使える
- 推し・コイン・衣装・学習体験の「型」は共通仕様（`app_common_kit` v0.2.0）を適用可能だが、簿記固有の学習体験の「型」9部品はまだ `yourwish_kentei` 側に実装されていない
- 仕訳入力UI（表形式テーブル・科目リストボックス・テンキー）の設計は `docs/journal_input_ui_v0.md`。実装はまず `ukalab-boki3` 側（`lib/journal_input/`）で行う方針
- 勘定科目一覧の下書きは `docs/accounts_draft_v0.md`（公式出題区分表との照合が未済）

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
