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
| `zka32101/yourwish_kentei` | v0.12.0 |

タグ作成（この環境からの `git push --tags` はネットワークプロキシにHTTP 403で拒否される）は、
`yourwish_kentei` リポジトリに追加した `.github/workflows/create-tag.yml`（workflow_dispatch、
手動トリガーのみ）経由で行う。`tag_name`・`target_sha`・`message` を入力して実行すると、
CI上でタグを作成・pushできる。`yourwish_kentei` は他プロジェクトとも共有する依存のため、
バージョン番号が他セッションの変更と衝突することがある（実例: v0.11.0は別の変更が先に
使用していたため、本リポジトリの変更はv0.12.0とした）。タグ作成前に `git fetch --tags` で
既存タグと重複しないか確認すること。

## 現状（2026-10-04時点）

- `pubspec.yaml`・`assets/exam/boki3.exam.json`（ExamConfig）・最小限の `lib/main.dart` のみ
- 問題データ（JSONL）は `assets/exam/boki3.questions.jsonl` に147問作成済み（journal型106問・choice型27問・worksheet型6問・ledger型8問（商品有高帳〈移動平均法〉1問、現金出納帳2問、当座預金出納帳1問、得意先元帳〈売掛金元帳〉1問、仕入先元帳〈買掛金元帳〉1問、仕入帳1問、売上帳1問）。固定資産の買換え、貸付金・借入金の利息天引き、固定資産税の見越し計上を追加。理論（choice型）は仕訳日計表・試算表の目的・主要簿の分類・転記の定義などの帳簿組織に関する問題を追加。定率法による減価償却（2027年度版で新規追加された項目。未償却残高×償却率で計算し、定額法と異なり年数が経つほど金額が小さくなる点を扱う。簡易な出題にとどめる方針に合わせ、計算の分かりやすい例題のみ）を仕訳2問・理論1問追加。固定資産の除却・廃棄および販売のつど売上原価勘定に振り替える方法は、勘定科目一覧にない科目（固定資産除却損・貯蔵品・売上原価）を要するため、科目一覧を独断で拡張しない方針により見送り。固定資産の購入・売却損益、前払金・前受金・仮払金・仮受金・未収入金・未払金・貸付金・預り金・小口現金、受取家賃・地代、貸倒損失・償却債権取立益・貸倒引当金戻入、法人税等、繰越利益剰余金の配当、売上原価の算定（しいくり）、電子記録債権・電子記録債務の発生〜決済、クレジット売掛金・受取商品券の精算、差入保証金、定期預金、当座借越、未払消費税の決算整理、雑損・雑益、費用の見越し（未払費用）、増資、仕入・売上の諸掛り（引取運賃・発送費）、証ひょう読み取りバリエーション、仕入戻し・売上戻り・仕入値引き・売上値引き、通貨代用証券（他人振出小切手・送金小切手・郵便為替証書）、資本的支出・収益的支出の区別、固定資産の期中取得（減価償却の月割り計算）、収入印紙の処理、精算表の貸倒引当金設定・減価償却と未払費用の複合パターン・消費税の決算整理・決算整理なしの基礎パターンなどをカバー。理論（choice型）は貸借対照表・損益計算書の区分、精算表の仕組み、減価償却の要素、伝票の種類、証ひょうの分類、勘定記入の法則、試算表の種類、仕入戻しの処理方向、通貨代用証券、資本的支出の定義なども追加。出典欄 `sourceRef` に根拠の区分表項目を明記。`test/questions_data_test.dart` で出典必須・貸借一致・ExamConfigとの整合性を機械検証）。過去問の転載はしない方針
- 第2問・第3問の出題形式の設計は `docs/question_types_v1_design.md`。精算表・財務諸表の穴埋めは `QuestionType.worksheet`（`yourwish_kentei` v0.10.0、PR#13）として実装・マージ済み
- 簿記3級に必須の「仕訳タイプ（借方・貸方の勘定科目＋金額を入力する表形式）」は `yourwish_kentei`（`QuestionType.journal`・`JournalLine`・`JournalAnswer`・`judgeJournal`）で実装済み。`PracticeSession`（演習セッション）のjournal対応（`answerJournal`）・worksheet対応（`answerWorksheet`）も実装・マージ済み（v0.9.1〜v0.10.0、PR#11・#13）
- `assets/exam/boki3.questions.jsonl` の仕訳（journal型）・理論（choice型）・精算表（worksheet型）問題を `PracticeSession` で連続出題する画面 `lib/practice/practice_page.dart` を実装。精算表入力UIは `lib/worksheet_input/`（表形式・セル選択・テンキー入力・セル単位の正誤表示、`lib/journal_input/` と対になる構成）。「学ぶ」タブの「問題を練習する（問題集）」から開ける。Playwrightで実機確認済み（journal/choice/worksheet混在、精算表5セル全入力→正解判定まで確認、console error 0件）
- 精算表（worksheet型）の入力セルを選択すると、横スクロールした先（画面外）にあっても自動でスクロールして見える位置まで追従する（`WorksheetTable` が `Scrollable.ensureVisible` を使用）。`test/worksheet_autoscroll_test.dart` でオフセット変化を検証
- 精算表（worksheet型）に、貸倒引当金の差額補充法設定と減価償却を組み合わせた総合決算整理パターン（blankCells 10個）を追加し、単一の決算整理事項だけだった既存問題から出題の難易度幅を広げた
- 「模擬」タブから、本試験形式（`level3_from_2027_04`：15問・60分・合格ライン総合70%、科目別出題数は仕訳10/帳簿伝票3/決算2）で1回通しで解く模擬試験モード `lib/mock_exam/mock_exam_page.dart` を実装。本試験と同じく解答中は正誤を表示せず、全問解答後に `yourwish_kentei` の `pickMockExamQuestions`・`scoreMockExam` でまとめて採点し、総合点・科目別得点・合否を表示する。`JournalQuestionView`・`ChoiceQuestionView`・`WorksheetQuestionView` に `revealResult: false` を追加し、模擬試験では即答で正誤を見せずに次の問題へ進めるようにした。`test/mock_exam_page_test.dart` で開始〜全15問解答〜結果表示までを検証
- `PracticePage`（「問題を練習する（問題集）」）の結果画面に「間違えたN問を復習する」ボタンを追加。`PracticeSession.records` から不正解だった qid を集め、`PracticePage(restrictToQids: ...)` でその問題だけに絞った復習セッションを開く（`test/practice_page_review_test.dart` で検証）
- 演習・模擬試験の解答を `lib/progress/progress_store.dart`（`SharedPreferences` による端末内保存）に記録し、ホーム画面に科目別の正答率カード `lib/progress/progress_summary_card.dart` を表示するようにした。正答率70%未満の科目は「苦手科目」として警告アイコン付きで強調する。`test/progress_summary_test.dart`・`test/progress_summary_card_empty_test.dart`・`test/progress_summary_card_filled_test.dart` で検証
- 第2問の補助簿記入（商品有高帳・現金出納帳など）向けに `QuestionType.ledger`（`yourwish_kentei` v0.12.0）を実装。`LedgerCell`（記入行×列グループ〈受入/払出/残高〉×項目〈数量/単価/金額〉）の `givenCells`/`blankCells` を `judgeLedger` でセル単位に採点する、`worksheet` 型と同じ設計パターン。入力UIは `lib/ledger_input/`（`WorksheetTable` と対になる構成、`LedgerTable`・`LedgerQuestionView` など）。商品有高帳（移動平均法）・現金出納帳・得意先元帳（売掛金元帳）・仕入先元帳（買掛金元帳）・仕入帳・売上帳の問題を計7問追加し、`PracticePage`・`MockExamPage` 双方で出題・採点できる（仕入帳・売上帳は `issue`/`balance` を使わず `receipt` のみの帳簿で、列フィルタリングが単一グループでも正しく動くことを兼ねて確認）。設計の詳細は `docs/question_types_v1_design.md`（Phase 2）。先入先出法で複数ロットが並存する一般ケースはPhase 2.5として先送り。`test/ledger_question_view_test.dart` で商品有高帳（数量・単価・金額の9列）・現金出納帳（金額のみ3列）それぞれ全セル入力→正解判定までを検証
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
