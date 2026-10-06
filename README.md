# うかラボ 簿記3級

日商簿記検定3級の学習アプリ（非公式）。日本商工会議所・各地商工会議所とは関係ありません。

## スコープの方針（簿記2級・AFPなど）

簿記2級は将来的に**このアプリに含める**方針。journal/ledger/worksheet型の入力UI・勘定科目エンジンを
ほぼ共用でき、`ExamConfig`も複数levelを前提にした設計（`level3_until_2027_03`/`level3_from_2027_04`）
のため、`level2_...`を追加する形で構造的に自然に拡張できる。ユーザー層も「3級→2級」と進む同じ学習者。

AFP・FP技能士など簿記と異なるドメインの資格は**別アプリ**にする方針。選択式・計算問題が中心で、
今回作り込んだ仕訳・帳簿・精算表の入力UIがほぼ使えず、勘定科目一覧などのドメイン知識も無関係。
ASOキーワード・ブランドが混ざるのを避けるため。ただし`yourwish_kentei`・`app_common_kit`という
共通エンジンはそのまま再利用する想定（モノレポの元々の設計思想どおり）。2026-10時点ではまだ着手していない。

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
- 問題データ（JSONL）は `assets/exam/boki3.questions.jsonl` に151問作成済み（journal型106問・choice型27問・worksheet型10問・ledger型8問（商品有高帳〈移動平均法〉1問、現金出納帳2問、当座預金出納帳1問、得意先元帳〈売掛金元帳〉1問、仕入先元帳〈買掛金元帳〉1問、仕入帳1問、売上帳1問）。固定資産の買換え、貸付金・借入金の利息天引き、固定資産税の見越し計上を追加。理論（choice型）は仕訳日計表・試算表の目的・主要簿の分類・転記の定義などの帳簿組織に関する問題を追加。定率法による減価償却（2027年度版で新規追加された項目。未償却残高×償却率で計算し、定額法と異なり年数が経つほど金額が小さくなる点を扱う。簡易な出題にとどめる方針に合わせ、計算の分かりやすい例題のみ）を仕訳2問・理論1問追加。固定資産の除却・廃棄および販売のつど売上原価勘定に振り替える方法は、勘定科目一覧にない科目（固定資産除却損・貯蔵品・売上原価）を要するため、科目一覧を独断で拡張しない方針により見送り。固定資産の購入・売却損益、前払金・前受金・仮払金・仮受金・未収入金・未払金・貸付金・預り金・小口現金、受取家賃・地代、貸倒損失・償却債権取立益・貸倒引当金戻入、法人税等、繰越利益剰余金の配当、売上原価の算定（しいくり）、電子記録債権・電子記録債務の発生〜決済、クレジット売掛金・受取商品券の精算、差入保証金、定期預金、当座借越、未払消費税の決算整理、雑損・雑益、費用の見越し（未払費用）、増資、仕入・売上の諸掛り（引取運賃・発送費）、証ひょう読み取りバリエーション、仕入戻し・売上戻り・仕入値引き・売上値引き、通貨代用証券（他人振出小切手・送金小切手・郵便為替証書）、資本的支出・収益的支出の区別、固定資産の期中取得（減価償却の月割り計算）、収入印紙の処理、精算表の貸倒引当金設定・減価償却と未払費用の複合パターン・消費税の決算整理・決算整理なしの基礎パターン・売上原価の算定（しいくり）・法人税等の計上（決算整理で新規計上するため残高試算表欄は空欄になるパターン）・貸倒引当金/減価償却/消費税を1枚にまとめた総合精算表・定率法による減価償却などをカバー。理論（choice型）は貸借対照表・損益計算書の区分、精算表の仕組み、減価償却の要素、伝票の種類、証ひょうの分類、勘定記入の法則、試算表の種類、仕入戻しの処理方向、通貨代用証券、資本的支出の定義なども追加。出典欄 `sourceRef` に根拠の区分表項目を明記。`test/questions_data_test.dart` で出典必須・貸借一致・ExamConfigとの整合性を機械検証）。過去問の転載はしない方針
- 第2問・第3問の出題形式の設計は `docs/question_types_v1_design.md`。精算表・財務諸表の穴埋めは `QuestionType.worksheet`（`yourwish_kentei` v0.10.0、PR#13）として実装・マージ済み
- 簿記3級に必須の「仕訳タイプ（借方・貸方の勘定科目＋金額を入力する表形式）」は `yourwish_kentei`（`QuestionType.journal`・`JournalLine`・`JournalAnswer`・`judgeJournal`）で実装済み。`PracticeSession`（演習セッション）のjournal対応（`answerJournal`）・worksheet対応（`answerWorksheet`）も実装・マージ済み（v0.9.1〜v0.10.0、PR#11・#13）
- `assets/exam/boki3.questions.jsonl` の仕訳（journal型）・理論（choice型）・精算表（worksheet型）問題を `PracticeSession` で連続出題する画面 `lib/practice/practice_page.dart` を実装。精算表入力UIは `lib/worksheet_input/`（表形式・セル選択・テンキー入力・セル単位の正誤表示、`lib/journal_input/` と対になる構成）。「学ぶ」タブの「問題を練習する（問題集）」から開ける。Playwrightで実機確認済み（journal/choice/worksheet混在、精算表5セル全入力→正解判定まで確認、console error 0件）
- 精算表（worksheet型）の入力セルを選択すると、横スクロールした先（画面外）にあっても自動でスクロールして見える位置まで追従する（`WorksheetTable` が `Scrollable.ensureVisible` を使用）。`test/worksheet_autoscroll_test.dart` でオフセット変化を検証
- 精算表（worksheet型）に、貸倒引当金の差額補充法設定と減価償却を組み合わせた総合決算整理パターン（blankCells 10個）を追加し、単一の決算整理事項だけだった既存問題から出題の難易度幅を広げた
- 「模擬」タブから、本試験形式（`level3_from_2027_04`：15問・60分・合格ライン総合70%、科目別出題数は仕訳10/帳簿伝票3/決算2）で1回通しで解く模擬試験モード `lib/mock_exam/mock_exam_page.dart` を実装。本試験と同じく解答中は正誤を表示せず、全問解答後に `yourwish_kentei` の `pickMockExamQuestions`・`scoreMockExam` でまとめて採点し、総合点・科目別得点・合否を表示する。`JournalQuestionView`・`ChoiceQuestionView`・`WorksheetQuestionView` に `revealResult: false` を追加し、模擬試験では即答で正誤を見せずに次の問題へ進めるようにした。`test/mock_exam_page_test.dart` で開始〜全15問解答〜結果表示までを検証
- `PracticePage`（「問題を練習する（問題集）」）の結果画面に「間違えたN問を復習する」ボタンを追加。`PracticeSession.records` から不正解だった qid を集め、`PracticePage(restrictToQids: ...)` でその問題だけに絞った復習セッションを開く（`test/practice_page_review_test.dart` で検証）
- 演習・模擬試験の解答を `lib/progress/progress_store.dart`（`SharedPreferences` による端末内保存）に記録し、ホーム画面に科目別の正答率カード `lib/progress/progress_summary_card.dart` を表示するようにした。正答率70%未満の科目は「苦手科目」として警告アイコン付きで強調する。`test/progress_summary_test.dart`・`test/progress_summary_card_empty_test.dart`・`test/progress_summary_card_filled_test.dart` で検証
- 間隔反復（直近で不正解のまま放置されている問題を優先出題する）を `lib/progress/review_priority.dart`
  （`reviewPriorityQids`）で実装。既存の解答記録（`ProgressStore.loadRecords()`）から、各qidの最新の
  解答が不正解だったものを抽出し、不正解のまま最も長く放置されている順に並べる。`yourwish_kentei` の
  `PracticeSession` には元々 `priorityQids`（出題順の先頭に優先出題する仕組み）が用意されていたが
  アプリ側では未使用だったため、新しいエンジン実装は不要だった。「問題を練習する（問題集）」を開く
  たびに `PracticePage._loadSession()` で計算し、優先出題中の問題には「苦手な問題を復習中」の表示を
  出す。`test/review_priority_test.dart`（優先順位の計算ロジック）・
  `test/practice_page_review_priority_test.dart`（実際に先頭に出題されることを確認）で検証
- 下部ナビの「記録」タブ（従来は `準備中` のプレースホルダー）を `lib/records/records_page.dart`
  （`RecordsPage`）として実装。科目別正答率カード（ホーム画面と同じ `ProgressSummaryCard`）に加え、
  間隔反復で復習待ちになっている問題の一覧と、まとめて復習セッションを開くボタンを表示する。
  実装の過程で2つの不具合を発見・修正した。(1) 下部タブは `app_common_kit` の `UkalabShell` が
  `IndexedStack` で管理しており、一度マウントされたタブは破棄・再ビルドされないため、起動時に
  読み込んだデータのまま固定され、他のタブで新しい解答記録を追加しても自動的には反映されなかった
  （`ProgressSummaryCard` も同じ不具合を抱えていたため合わせて修正）。`lib/progress/progress_revision.dart`
  の `ValueNotifier<int>`（解答記録が追加されるたびに増える版数）をリッスンし、変化があれば
  明示的に読み直す形で解決した。(2) 模擬試験の結果画面（`MockExamPage._finish()`）が出題数ぶん
  （15件）の `addRecord` を `unawaited` で並行に呼んでいたため、`SharedPreferencesProgressStore`
  の読み込み→追記→書き込みが競合し、ほとんどの記録が失われていた。`await` で順番に書き込む形に修正。
  `test/records_page_empty_test.dart`・`test/records_page_review_test.dart`・
  `test/records_page_live_update_test.dart`（タブを再マウントせずに自動更新されることを確認）で検証。
  `flutter build web` + Playwrightで実機確認（記録タブを開いたまま演習で1問不正解にし、タブに
  戻らず裏側のナビゲーションだけで正答率・復習待ち一覧が自動更新されることを確認、console error 0件）
- 下部ナビの「設定」タブ（従来はアプリ説明のみの静的ページ）に、解答記録をリセットする機能を追加。
  `ProgressStore` に `clearRecords()` を追加し（`SharedPreferencesProgressStore`・`InMemoryProgressStore`
  両方に実装）、`lib/settings/settings_page.dart`（`SettingsPage`）から確認ダイアログを経て呼び出す。
  リセット後は `progressRevision` を進め、ホーム・記録タブが開いたままでも正答率・復習待ち一覧が
  即座に空へ更新される。`test/settings_page_test.dart`（キャンセル時は削除されないこと・確定時に
  削除されリセット完了のスナックバーが出ることを確認）で検証。`flutter build web` + Playwrightで
  実機確認（確認ダイアログ→リセット→スナックバー表示まで、console error 0件）
- 「学ぶ」タブに科目別の練習モードを追加。`PracticePage` に `subjectId`（絞り込み）・`title`
  （AppBarタイトルの上書き）パラメータを追加し、第1問 仕訳／第2問 帳簿・伝票等／第3問 決算の
  いずれかだけを集中的に解けるようにした（従来は147問全部をまとめて1セッションにするか、
  「間違えた問題を復習する」の qid 絞り込みしかできなかった）。開発確認用だった「仕訳の問題を試す
  （サンプル）」ボタン（固定1問・`ProgressStore` に記録されない）は実用上の価値が薄いため削除し、
  科目選択ボタンに置き換えた。`test/learn_subject_practice_test.dart` で検証。実装の過程で、
  widget テストから実機相当の `SharedPreferencesProgressStore`（`appProgressStore`）を経由する画面を
  開くとテスト環境にプラグイン実体がなく `MissingPluginException` になる問題に気づき、
  `SharedPreferences.setMockInitialValues({})` を使うよう修正（従来は `ProgressStore` に依存しない
  静的な画面しかフルアプリ経由でテストしていなかったため表面化していなかった）。
  `flutter build web` + Playwrightで実機確認（科目選択→該当科目のみ出題されることを確認、
  console error 0件）
- 模擬試験の結果画面（`MockExamPage` の `_MockExamResultView`）に「間違えた問題を復習する」ボタンを
  追加。`PracticePage._ResultView` と同じパターンで、不正解だった qid を集めて
  `PracticePage(restrictToQids: ...)` の復習セッションを開く（従来は模擬試験後にそのまま復習に
  入る導線がなく、「記録」タブの間隔反復に頼るしかなかった）。`test/mock_exam_page_test.dart` に
  復習ボタンのタップ〜復習セッション開始までの検証を追加
- 「設定」タブにライト／ダーク／端末設定の3択で表示モードを切り替える機能を追加。
  `lib/settings/theme_mode_store.dart` の `ValueNotifier<ThemeMode>`（`appThemeMode`）を
  `SharedPreferences` で永続化し、`MaterialApp` の `themeMode` に直接バインドする
  （`MaterialApp` 自体がリスナーのため、`IndexedStack` でマウントされたままの他タブにも
  選択直後に反映される）。起動時は `main()` で `loadSavedThemeMode()` を await してから
  `runApp` するため、誤った配色が一瞬表示されるちらつきが起きない。
  `test/theme_mode_test.dart` で検証（保存・復元・不正値のフォールバック・設定タブでの
  切り替えでMaterialAppのthemeModeが変わること）。`flutter build web` + Playwrightで
  実機確認（設定タブで「ダーク」を選ぶと即座に全体に反映され、他タブへ移動しても
  維持されることを確認、console error 0件）
- 問題データ（`boki3.questions.jsonl`・`boki3.exam.json`）の読み込みキャッシュを
  `lib/exam_data/exam_data_cache.dart`（`loadQuestions`・`loadExamConfig`）に集約。従来は
  `PracticePage`・`RecordsPage`・`MockExamPage`・`ProgressSummaryCard` の4箇所がそれぞれ
  独立に同じファイルを読み込み・パースしており、タブを行き来するたびに147問のJSONLを
  再パースしていた。アプリ起動中は最初の呼び出し結果（`Future`）をキャッシュして使い回す
  ようにし、2回目以降の表示を高速化した。`test/exam_data_cache_test.dart`
  （2回目の呼び出しが同じFutureインスタンスを返すことを確認）で検証。`flutter build web` +
  Playwrightで実機確認（初回の「問題を練習する」表示まで約1.5秒かかっていたのが、タブを
  行き来して再度開くと0.5秒未満で表示されることを確認、console error 0件）
- 模擬試験の結果画面に「解答結果の詳細を見る」ボタンを追加し、`lib/mock_exam/mock_exam_review_page.dart`
  （`MockExamReviewPage`）で全問の正誤・自分の解答・正解・解説をまとめて振り返れるようにした。
  「間違えた問題を復習する」（解き直し）とは別に、本試験前に「どこをどう間違えたか」を確認できる
  画面がなかったギャップを埋める。新しいデータモデルは追加せず、出題した `Question` リストと
  解答記録（`Map<String, Object?>`）に対して `judgeJournal`・`judgeWorksheet`・`judgeLedger` を
  再計算するだけで実現し、各問題種別の表示は既存の `JournalResultBanner`・`WorksheetResultBanner`・
  `LedgerResultBanner`（journal/worksheet/ledger型の入力画面で使っているものをそのまま再利用）＋
  choice型用に新規の簡易表示で構成した。`test/mock_exam_page_test.dart` にレビュー画面を開いて
  1問目・15問目（スクロール）・不正解表示までを検証する手順を追加。`flutter build web` +
  Playwrightで全タブ巡回のスモークテストを実施（console error 0件）。15問の対話的な自動操作は
  （選択肢の座標が問題文の行数で変動し自動化コストが高いため）widgetテストでの検証で代替した
- 第2問の伝票記入（入金・出金・振替伝票）を、実際の伝票の見た目で再現する専用UI `lib/voucher_input/`
  （`VoucherQuestionView`）を追加。新しい `QuestionType` は増やさず、既存の `journal` 型データを
  そのまま使う（`topicId` が `voucher_payment`/`voucher_receipt`/`voucher_transfer` の問題だけ
  `PracticePage`・`MockExamPage` 側で判定して切り替える）。入金伝票・出金伝票は、現金側が伝票の
  種類から自明（入金伝票は借方が現金、出金伝票は貸方が現金）なため、実物の伝票と同じく相手科目・
  金額の2項目だけを入力させる簡易フォームにし、現金側は自動的に補って通常の仕訳判定（`judgeJournal`）
  にかける。振替伝票は現金の受け払いを伴わないため、既存の `JournalQuestionView`（借方・貸方の
  表形式入力）をそのまま使い、見た目だけ伝票風の枠（`VoucherSlipFrame`）に入れる。配色は実物の
  伝票の慣習（入金伝票は赤系、出金伝票は青系、振替伝票は黒系の用紙）に合わせた。
  `test/voucher_question_view_test.dart` で3種類とも検証済み。`flutter build web`・ローカルの
  CanvasKitアセット・Playwrightで実機のレンダリングも確認（3種類の配色・簡易フォーム・通常の
  仕訳テーブルがそれぞれ正しく表示され、console error 0件）
- 第2問の証ひょう読み取り問題（`topicId: voucher_reading`）向けに、領収書・請求書などの記載内容を
  書類風のカードで表示する `lib/evidence_input/`（`EvidenceQuestionView`）を追加。新しい画像アセット
  は使わず、既存の `prompt` テキスト（`「品名A 5個×1,000円＝5,000円、...」` のように証ひょうの内容を
  `「」` で囲む自作ルールで統一済み）をパースして、経緯の説明文・証ひょう風カード（タイトル・項目・
  合計の強調表示）・短縮した指示文の3つに分解表示する（`EvidenceDocument.parseEvidenceDocument`）。
  `「」` で囲まれていない問題（証ひょうの内容を地の文だけで説明しているもの）は、通常の
  `JournalQuestionView` にそのままフォールバックする。本格的な画像添付（写真・PDF）はアセット管理・
  採点ロジックへの影響が未検討なトレードオフがあるため見送り、既存のテキストデータだけで実現できる
  範囲にとどめた。`test/evidence_document_test.dart`（パース）・`test/evidence_question_view_test.dart`
  （表示・採点・フォールバック）で検証済み。`flutter build web` + Playwrightで実機のレンダリングも
  確認（領収書・納品書（兼請求書）・「」なしフォールバックの3パターンとも正しく表示、console error 0件）
- 第2問の補助簿記入（商品有高帳・現金出納帳など）向けに `QuestionType.ledger`（`yourwish_kentei` v0.12.0）を実装。`LedgerCell`（記入行×列グループ〈受入/払出/残高〉×項目〈数量/単価/金額〉）の `givenCells`/`blankCells` を `judgeLedger` でセル単位に採点する、`worksheet` 型と同じ設計パターン。入力UIは `lib/ledger_input/`（`WorksheetTable` と対になる構成、`LedgerTable`・`LedgerQuestionView` など）。商品有高帳（移動平均法）・現金出納帳・得意先元帳（売掛金元帳）・仕入先元帳（買掛金元帳）・仕入帳・売上帳の問題を計7問追加し、`PracticePage`・`MockExamPage` 双方で出題・採点できる（仕入帳・売上帳は `issue`/`balance` を使わず `receipt` のみの帳簿で、列フィルタリングが単一グループでも正しく動くことを兼ねて確認）。設計の詳細は `docs/question_types_v1_design.md`（Phase 2）。先入先出法で複数ロットが並存する一般ケースはPhase 2.5として先送り。`test/ledger_question_view_test.dart` で商品有高帳（数量・単価・金額の9列）・現金出納帳（金額のみ3列）それぞれ全セル入力→正解判定までを検証
- `yourwish_kentei` v0.4.0では `LevelConfig.subjectQuestionCounts`（科目別の出題数配分）も追加された（別PR）。簿記3級の大問別出題数に使える
- 推し・コイン・衣装・学習体験の「型」は共通仕様（`app_common_kit` v0.2.0）を適用可能だが、簿記固有の学習体験の「型」9部品はまだ `yourwish_kentei` 側に実装されていない
- 仕訳入力UI（表形式テーブル・科目リストボックス・テンキー）の設計は `docs/journal_input_ui_v0.md`。実装はまず `ukalab-boki3` 側（`lib/journal_input/`）で行う方針
- 勘定科目一覧は `docs/accounts_v1_official.md`（確定版 v1。商工会議所の公式出題区分表PDF（2026-07-31最終改定、2027-04-01施行）をユーザーが提供し、照合済み。ただし2026年度中〜2027年3月実施分の旧区分表はまだ一次資料未入手）
- `/code-review` でこれまでの変更（補助簿記入の設計〜精算表データ拡充まで）をレビューし、見つかった不具合3件を修正した。
  (1) `MockExamPage._finish()` に二重実行ガードを追加。制限時間切れのTimerと最終問題の「次へ」連打がほぼ同時に
  発生すると、出題数ぶんの `addRecord`（読み込み→追記→書き込み）が並行実行され記録が壊れる恐れがあった
  （`test/mock_exam_double_finish_test.dart` で回帰テスト、修正前に実際に30件へ壊れることを確認してから修正）。
  (2) `VoucherSlipFrame`（入金・出金・振替伝票の枠）が `Colors.red.shade50` など固定のMaterial色を使っており、
  後から追加したダークモードで背景が明るいまま・文字が白のままになり低コントラストになっていた不具合を修正
  （`Theme.of(context).brightness` を見て、ダーク時は濃い用紙色＋ライトモードと同じアクセント色にする）。
  (3) `parseEvidenceDocument`（証ひょうカードのパーサー）が `lastIndexOf('」')` を使っており、将来
  `「」` で囲んだ語句が2箇所以上ある問題文では無関係な区間まで証ひょうの内容に巻き込む可能性があった
  （現行データでは未発生）。最初に閉じる `」` だけを使うように修正し、回帰テストを追加。
  なお、`LedgerInputController` が `WorksheetInputController` とほぼ同じロジックを重複して持っている点も
  指摘されたが、両方とも独立にテスト済みで動作しているため、リスクに見合わないと判断し今回は見送った。
- 第2問の補助簿記入（ledger型）問題データを4問追加（計12問）。worksheet型と同様に手薄だったため拡充した。
  既存の帳簿種別（得意先元帳・仕入先元帳・現金出納帳・当座預金出納帳）に、返品（売上戻り・仕入戻し）や
  出資の受入・雑収入など、既存パターンよりやや応用的な取引を組み込んだバリエーションを追加
  （`accounts_receivable_ledger_return`・`accounts_payable_ledger_return`・`cash_book_capital`・
  `checking_account_book_variation`）。既存の `LedgerCell`（`receipt`/`issue`/`balance` グループ）の
  スキーマのまま表現できることを確認済み。先入先出法（複数ロット並存）は従来どおりPhase 2.5として先送り。

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
