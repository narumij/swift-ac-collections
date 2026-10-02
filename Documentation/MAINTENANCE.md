<!-- CodexとClaudeによるCodexとClaudeのためのメモ -->

# Documentation maintenance notes

この文書は、公開ドキュメント、コメントドック、Swift-DocC、およびCHANGELOGを継続的に整備するための作業連絡と判断基準をまとめる。

ドキュメントに関する作業を行ったCodexおよびClaudeは、作業結果、残件、検証内容をこの文書へ都度反映すること。長期的に有効な知見は作業ログだけに残さず、該当する規則へ反映する。

## User requests for the next session

次回のドキュメント作業で優先してほしい内容をユーザーが書く欄。この欄に記載がある場合、CodexおよびClaudeは`Current handoff`より先に読み、最新のユーザー要望として優先する。完了した項目を勝手に削除せず、完了済みの要望へ移すか、ユーザー確認後に整理する。

<!-- ユーザー記入欄: この下へ追記 -->

### ビジョン

- 公開APIの意味、制約、計算量を、実装を読まなくても正しく把握できる状態を維持する
- 日英の案内文書、コメントドック、DocC、API一覧の内容を同期する
- DocCの警告と生成結果を、公開前にCIで継続的に検証する

### 優先事項

- 2026-10-02 15:45 JST ユーザー要望: Test as Specificationと現行実装を根拠に、公開メソッド・公開関数のコメントドックに不備がないか確認し、必要な修正を行う
  - 公開APIは型別の連番テスト、共有Viewテスト、API Matrixと照合する
  - 説明、引数名、戻り値、事前条件、失敗条件、重複要素の扱い、Indexの有効性、計算量、所有権と破棄責任を確認する
  - 1型または1経路で不備を見つけた場合、4型と共有Viewの対応する公開APIへ横展開する
  - 原木および内部APIのコメントドックは監査・修正対象に含めず、公開仕様を確定するために必要な場合だけ内部テスト・実装・Design文書を根拠として参照する
  - テストだけでは意味を確定できない場合は実装とDesign文書を確認し、推測でコメントドックを変更しない
  - 修正後はRelease DocCを`--warnings-as-errors`で生成し、生成ページのTopicsとリンクも確認する

- メイン担当は定期的にこの文書確認する癖をつけること
- startIndexとendIndexの記述は標準に倣って欲しい

### 相談事項

- DocCの手動Topicsは`API-Matrix.md`と`API-Matrix-View.md`を基準に、検索・挿入・削除・範囲操作などへ広げる。4型の具象型ページだけでなく、共通protocolのDefault ImplementationsやViewへの導線をどこへ置くかは引き続き検討する

### 連絡事項

- この文書のユーザー記入欄を更新する場合は、日付に加えて時刻も記載する
- 2026-10-02 20:48 JST ユーザー要望: 公開ドキュメントメンテナンスと同様に`Tests/TESTING.md`も定期的にレビューする。ドキュメント監査中にテスト仕様の不足、陳腐化、実装との不一致、判断待ちを見つけた場合は、本ユーザー記入欄の`保留中の判断・懸念`へ連絡事項として追記する
- 2026-10-02 16:02 JST ユーザー要望: Test as Specificationとの照合中に公開仕様として疑問が残った点は、推測で確定せず、この文書の`保留中の判断・懸念`へ連絡事項として記録する
- 最後に作業したモデル名とバージョンを記録する
- 完了済みログを無制限に蓄積しない。恒久的な知見は規則へ移し、`Current handoff`は直近の状況を中心に保つ

### 停止条件

- 公開APIの意味を実装やテストから確定できない場合は、推測で文書化せずユーザーへ確認する
- 日英どちらを正とするか判断できない差異を見つけた場合は、一方へ機械的に合わせず保留事項として記録する

### 保留中の判断・懸念

- 2026-10-02 20:48 JST: `Tests/TESTING.md`の`Current handoff`に、改名済みの`RedBlackTreeMappedValuesView._isdentical(to:)`が「未結線・削除判断待ち」として残っており、完了済みログと矛盾する。テスト側の次回メンテナンスでスナップショットから削除し、実在する未結線APIだけに同期する必要がある
- 2026-10-02 16:36 JST: Combining系コメントの既存`Important`は「十分な空き容量がある場合は`formUnion` / `union` / `meld` / `melding`推奨」としているが、容量条件と推奨APIの対応根拠がTest as Specificationから確定できない。設計意図は、逐次挿入を素直に回すO(*n* log(*m + n*))経路と、TimSort等で入力をソート済みにしてからO(*n + m*)でマージする経路の選択。ただし総コストは入力の既ソート性、ソート費用、一時メモリ、CoW、要素数に依存するため、単純な「十分な空き容量」だけでは推奨条件を表現しきれない可能性がある。意味・重複規則・計算量の文書化は行ったが、性能推奨の書き換えは代表的な入力分布でのベンチマークと実装経路の再確認後に行う。
- 2026-10-02 16:18 JST: `RedBlackTreeKeyValueRangeView.values`が返す`RedBlackTreeMappedValuesView`について、要素subscriptと`swapAt`の公開契約はView内の有効Indexを要求するが、現行実装は同じ木のView外Indexを明示的に範囲拒否していない。ソースにも範囲制限のTODOがある。公開仕様の変更ではなく事前条件検査の実装・Death Test課題として、別フェーズで対応要否を判断する。
- 2026-10-02 16:24 JST: MultiMapの通常`insert`が同値キー群の末尾へ追加して挿入順を保持することはInsertion Testsで確定した。一方、hint付き`insert`が同値キー群内の順序へ与える影響はテストが戻りIndexだけを検証しており、公開契約として未確定。hintは検索結果や挿入可否を変えないが、multi型の同値要素間順序も変えないと保証するかは、専用Test as Specificationを追加してから文書化する。
- API Matrix上の多くの共通APIが、各型のDocCでは`Default Implementations`配下に入る。今回追加した共通操作ガイドから各操作の個別シンボルへ、さらに細かいリンクを追加する必要があるかは公開結果を見て判断する
### 完了済みの要望

(ユーザーが確認したら各項目を整理します)

- 2026-10-03 Claude (Sonnet 5): 上記2026-10-02 16:22 JST保留事項(Viewの公開同一性判定名`_isIdentical(to:)`/`_isdentical(to:)`の綴り不一致)について、ユーザーから「凡ミスなのでリネームでよい」と判断が出たため対応。`RedBlackTreeMappedValuesView`に加え、同じ綴りミスを持つ`RedBlackTreeKeyValueRangeView._isdentical(to:)`(`==`/`<`内部実装から呼ばれていた)も発見し、両方`_isIdentical(to:)`へ統一。Sources/Tests内の旧綴り参照が無いことを確認し、全体テスト0失敗。`API-Matrix.md`の該当行(`_isIdentical(to:)` / `_isdentical(to:)`という旧綴り併記)はClaudeの編集範囲外のため未更新、同期が必要。保留事項から本項目を削除した。
- 2026-10-03 Claude (Sonnet 5): 上記2026-10-02 15:34 JST保留事項(`UnsafeTreeV2+KeyValue.swift`のoptional key subscriptが`.move()`後のnil代入で二重解放を起こす件)を修正した。`.move()`を`.pointee`読み取り(コピー)に変更し、既存キー上書き分岐も`.initialize(to:)`から`.pointee =`代入に変更。`_MappedValue`は常にCopyableのためコピーへの変更は型制約上問題ない。回帰防止テスト2件を`RedBlackTreeDictionary_6_RemovalTests.swift`に追加、全体テスト0失敗を確認。詳細は`Tests/TESTING.md`の完了済み要望を正とする。これにより「move済みstorageを通常削除で再度deinitializeしない」という所有権契約への既知の未適合は解消された。保留事項から本項目を削除した。
- 2026-10-02 Codex (GPT-5): 前回のCHANGELOG更新以降を再監査。原木・fixture・Legacyのテストターゲット分離とテスト拡充は既存のテスト再編・内部テスト追加の記載へ包含し、重複追記しなかった。利用者影響のある`OptionalArray1D` / `OptionalArray1DView`の参照型要素nil代入時の二重解放修正だけを`Unreleased / Fixed`へ追加した。
- 2026-10-02 15:34 JST Codex (GPT-5): 原木`Foundamental`テストをTest as Specificationとして精査し、公開仕様とは別の内部契約を品質方針へ定義した。比較注入、LLVM移植監査、赤黒木不変条件、番兵、unique/multi、範囲・距離、tracking tag、seal、Death Test、node/payloadレイアウト、poison塗り分け、所有権と破棄責任を既存Design文書へ反映。`RedBlackTreePair`とthree-way比較の内部値契約も実装へ再照合した。原木専用Fixture二種の責務と非責務を`Fixtures.md`へ追記し、Fixture固有の実装を製品仕様として扱わない境界を記録した。
- 2026-10-02 14:12 JST Codex (GPT-5): 追加したイニシャライザ、共通操作ガイド、View TopicsをCI相当のローカルRelease生成で検証した。`--disable-sandbox`を付けた`swift package -c release generate-documentation --target RedBlackTreeCollections --warnings-as-errors`が警告・エラーなく成功。生成JSON上で4型の全イニシャライザが各`Creating` Topicsへ収容され、3種類のViewの手動Topicsと、4型・3 Viewから`Common Operations`へのリンクが解決されていることを確認した。
- 2026-10-01 Codex (GPT-5): `CHANGELOG.md`の現行本文を最後に確定したmerge以降の差分を反映。既存Unreleasedとの重複を避け、Swift-DocCカタログと型/View/共通操作Topics、Release DocC検証・artifact・GitHub Pages公開CI、標準ライブラリ準拠のメンバー分類、macOS 15への最小バージョン変更を追記した。
- 2026-10-01 12:56 JST Codex (GPT-5): 4型のDocC分類をAPI Matrix準拠からSwift標準`Set`/`Dictionary`準拠へ改訂。`Testing for Membership`、`Finding Elements/Keys`、`Adding and Updating Elements/Keys and Values`、`Removing Elements/Keys and Values`、`Combining Sets/MultiSets/MultiMaps`、`Merging Dictionaries`、`Transforming`、`Comparing`、`Reserving Storage`へ整理した。独自のIndexおよびRange/Bound分類は維持し、自動分類に残っていた`erase`、`formIndex`、`merge`/`merging`等の全オーバーロードも手動Topicsへ収容した。
- 2026-10-01 12:43 JST Codex (GPT-5): `API-Matrix.md`と`API-Matrix-View.md`を基準にDocCの導線を整備。4型に共通する検索、挿入・更新、削除、Range/Boundの意味を説明する`CommonOperations.md`を追加し、モジュールページと4型ページからリンクした。KeyOnly Range View、KeyValue Range View、MappedValues Viewには、基本状態、Index検証、参照・更新、削除、走査・比較をMatrixの区分に沿って手動Topics化した。
- 2026-10-01 12:36 JST Codex (GPT-5): `main`のCIによるGitHub Pages初回公開が成功し、常設URLから閲覧できることをユーザーが確認した。
- 2026-10-01 12:27 JST Codex (GPT-5): ドキュメントメンテナンス専用の作業連絡文書として、この`Documentation/MAINTENANCE.md`を作成した。

## 文書の役割と正本

| 対象 | 役割 |
| --- | --- |
| `README.md` / `README.ja.md` | パッケージ全体の入口、導入方法、主要な利用案内 |
| `Documentation/*.md` / `*.ja.md` | 各コレクションの利用者向けガイド。日英ペアで管理する |
| `Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/` | Swift-DocCのモジュールページ、手動Topics、補足記事 |
| Swiftソース内の`///` | 公開宣言に直接対応するAPIリファレンス |
| `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md` | 4つのコレクション型における公開APIの実装状況 |
| `Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md` | View系公開APIの実装状況 |
| `Sources/RedBlackTreeCollections/Documentation/Quality-Checklist.md` | 品質要件と検証観点 |
| `Sources/RedBlackTreeCollections/Documentation/Design/` | 内部設計と実装上の判断 |
| `CHANGELOG.md` | リリース利用者に影響する変更の記録 |

APIの有無は実装とAPI Matrix、挙動は実装とテストを照合して判断する。説明文書だけを根拠に別の説明文書を更新しない。

## メンテナンス規則

### DocC Topics

- Topicsの分類名と構成は、利用者がSwift標準ライブラリから類推できるよう、原則として標準`Set`と`Dictionary`に合わせる
- Set系では`Testing for Membership`、`Adding and Updating Elements`、`Removing Elements`、`Combining Sets`など、Dictionary系では`Accessing Keys and Values`、`Adding and Updating Keys and Values`、`Removing Keys and Values`、`Merging Dictionaries`などの利用目的別分類を優先する
- MultiSetとMultiMapも、対応するSetまたはDictionaryの分類を基礎とし、重複要素・重複キー固有の操作を同じ文脈へ配置する
- `API-Matrix.md`と`API-Matrix-View.md`はTopicsの分類体系として使わない。公開メンバーの掲載漏れ、4型間の差異、View間の差異を確認するチェックリストとして使う
- Index、Range、Boundなど標準コレクションより強く表面化している独自APIは、本ライブラリ固有のTopicsとして追加する
- 標準`Sequence`由来の汎用メソッドを具象型ページへ無制限に重複掲載せず、主要操作以外は`Default Implementations`に残す

### 日英文書

- `Documentation`直下に日英ペアがある文書は、片方を変更したら他方も同じ作業で確認する
- 見出し、コード例、注意事項、公開API名を対応させる
- 逐語訳より、Swift APIとして同じ意味と制約を伝えることを優先する

### コメントドック

- DocCへ公開する説明だけを`///`で記述する
- 日本語の実装メモ、設計途中の覚え書き、保留事項は`//`を使用する
- Index操作の公開挙動は、ライブラリ固有の仕様がTest as Specificationで明示されていない限り、現行Swift標準ライブラリの`String`を比較基準とする。判断に迷う場合は`Tests/RedBlackTreeTests/EtcTests.swift`へ同じ入力による比較テストを置いて確認する
- 宣言の実際の引数名と`- Parameter`の名前を一致させる
- 戻り値、重複要素の扱い、Indexの無効化条件、計算量を実装と照合する
- コレクションの順序性は`sorted`と表現する
- MultiSetとMultiMapについて、要素またはキーが一意であると誤解させる説明を避ける
- 1型で誤りを見つけた場合は、Set、MultiSet、Dictionary、MultiMapおよび共有Viewへ横展開して確認する

### Test as SpecificationからDesignへの反映

1. テスト名と期待値だけでなく、Fixture、呼び出す実装、失敗条件を読む
2. 公開APIの契約、内部実装の契約、Fixture固有の便宜、coverage専用ケースへ分類する
3. 内部契約は現行実装へ逆照合し、テストと実装が同じ誤りを共有していないか確認する
4. Fixtureの代用キー、個別allocation、固定容量などを製品仕様として文書化しない
5. 所有権、計算量、移植元との一致、到達不能性など、テストだけで表現できない理由をDesign文書へ記録する
6. 設計契約と現行実装が一致しない場合、設計へ実装を合わせたことにせず、`保留中の判断・懸念`へ既知差分として記録する
7. 同じ事実を複数文書へ複製せず、物理配置はMemory Layout、所有権はNode Storage、安全化はMemory Safety、層と注入はInternal Architecture、端点と反復はRangeへ配置する
8. Overviewと関連文書から導線を張り、相対リンクが実在することを確認する

原木については、実行可能な内部契約とLLVM libc++との構造比較を別の証拠として扱う。
到達不能な移植由来コードをカバレッジ率だけのために書き換えない。

### API MatrixとCHANGELOG

- API Matrixの状態は、現行ソースとテストを確認してから変更する
- CHANGELOG更新時は、対象とする開始コミットまたはリリースタグを明確にする
- 内部整理だけの変更と、利用者から見えるAPI・挙動変更を区別する
- 既存リリース欄を遡って書き換える場合は、ユーザーの明示的な意図を確認する

### CHANGELOG更新手順

1. ユーザーが指定した更新範囲を確認する。`前回更新以降`、特定のリリースタグ以降、特定コミット以降を混同しない
2. `前回更新以降`の場合は、`CHANGELOG.md`の内容が実質的に最後に変わったコミットを起点にする。通常の`git log -- CHANGELOG.md`だけで決めず、mergeを含む場合は`git log --full-history -m -- CHANGELOG.md`と各コミットのblob IDも確認する
3. 起点から`HEAD`までのコミット済み差分に加え、作業ツリーの未コミット差分も対象に含める
4. コミットメッセージだけで要約せず、変更ファイル、公開宣言、テスト、利用者向け文書を照合する
5. 現在の`Unreleased`を先に読み、既に意味として含まれている変更を重複掲載しない
6. Keep a Changelogの`Added`、`Changed`、`Deprecated`、`Removed`、`Fixed`、`Security`へ利用者視点で分類する。内部リファクタリングは、公開挙動、対応環境、信頼性、保守上の重要事項へ影響する場合だけ掲載する
7. API追加・削除・改名、対応プラットフォーム変更、互換性変更、公開ドキュメントの新設、CIによる配布方法の変更は掲載候補として必ず確認する
8. 過去のリリース欄は原則変更せず、未リリースの変更は`Unreleased`へ追記する。過去欄を修正する必要がある場合はユーザーへ確認する
9. 更新後は対象範囲の差分とCHANGELOGの各項目を再照合し、`git diff --check`を実行する

更新結果を作業連絡へ記録するときは、採用した起点と、重複を避けるために既存記載へ包含した変更があることも残す。

## Swift-DocC運用

公開用のシンボルはRelease構成から抽出する。

生成と警告検証:

```console
swift package -c release generate-documentation \
  --target RedBlackTreeCollections \
  --warnings-as-errors
```

ローカルプレビュー:

```console
swift package -c release --disable-sandbox preview-documentation \
  --target RedBlackTreeCollections
```

- CIでも`-c release`を指定する
- DocC警告は`--warnings-as-errors`で失敗として扱う
- GitHub Pages用には`--transform-for-static-hosting`と正しい`--hosting-base-path`を指定する
- DocC生成物にはWindows非互換の文字を含むファイル名があり得るため、通常artifactはディレクトリを直接渡さず`tar.gz`へ格納する
- GitHub Pages artifactはPages専用Actionへ生成ディレクトリを渡す
- 生成物はリポジトリへコミットしない
- 手動Topicsを変更した場合は、リンク解決だけでなく生成後のTopics表示件数と分類も確認する

## 検証チェックリスト

ドキュメント変更の内容に応じて、必要な項目を確認する。

- 日英ペアの差分確認
- 4型およびKeyOnly/KeyValue Viewへの横展開確認
- コメントドックの引数名、戻り値、計算量の照合
- API Matrixとの整合
- DocCのRelease生成と`--warnings-as-errors`
- 生成済みDocCページのTopicsとリンク
- workflow YAMLの構文
- `git diff --check`

文書だけの変更では通常、全体テストを必須としない。ただし、コード例をテストで検証している文書や、コンパイル対象のコメントドックに影響する変更では、対応するビルドまたはテストを実行する。

## Current handoff

- 2026-10-02 20:52 JST Codex (GPT-5): 公開削除系APIの基本区切りを完了。4型の`popFirst` / `popLast`、`removeFirst` / `removeLast`、`remove(at:)`、`removeAll(keepingCapacity:)`、`erase(_:)`、`erase(where:)`、Setの`remove(_:)`、Dictionaryの`removeValue(forKey:)`、MultiSet / MultiMapの`eraseUnique` / `eraseMulti`をRemoval Testsと実装へ照合し、空時の戻り値、最小・最大要素、Indexの事前条件、次Indexの返却を文書化した。Bound expressionによる単一・範囲・条件付き削除と、Set / MultiMapの`erase(exactly:)`の失敗時`nil`も追記。Claudeが完了した`_isIdentical(to:)`改名に合わせてAPI Matrixの旧綴り併記を削除した。Bound / Insertion関連118テストが成功し、Release DocCの`--warnings-as-errors`生成も成功。`TESTING.md`の陳腐化した未結線一覧はユーザー記入欄の保留事項へ記録済み。次はAPI Matrixの残りからutility / protocol conformance / transformation系の公開コメントを監査する。
- 2026-10-02 16:36 JST Codex (GPT-5): 公開一括挿入・結合系の監査を完了。Setのmerge / merging、MultiSetとMultiMapのinsert(contentsOf:) / inserting(contentsOf:) / meld / melding、Dictionaryのmerge / mergingを型別Insertion・SetAlgebra・TransformingAndCombining Testsと実装へ照合した。unique型の重複破棄、multi型の全出現保持、Dictionary combineの引数順（現在値、otherの値）、mutating / nonmutating差、入力非変更、消費される`other`を文書化した。関連84テストが成功し、Release DocCの`--warnings-as-errors`生成も成功。既存の容量条件付き推奨文は根拠未確定として保留事項へ記録。次は削除系公開APIを監査する。
- 2026-10-02 16:25 JST Codex (GPT-5): 公開挿入・更新系の基本区切りを完了。4型の単一insert、Set update、MultiSetのIndex指定update、Dictionaryのinsert / updateValue、MultiMapのIndex指定updateValue、hint付き操作、要素・キー・default・MultiMap値群subscriptを型別Insertion Testsと現行実装へ照合した。unique型は既存要素を返して重複挿入しないこと、multi型は必ず新しい出現を追加すること、Dictionary default subscriptはreadだけでは挿入せずmutation時に挿入することを明文化した。MultiMapの通常insertが同値キー群内の挿入順を保持することもTest as Specificationで確定し、以前の検索系保留を解消した。hint付きmulti挿入の同値要素間順序だけは未確定として保留事項へ残した。Insertion Tests 49件が成功し、Release DocCの`--warnings-as-errors`生成も成功。次は一括挿入・merge / union / meld系を監査する。
- 2026-10-02 16:23 JST Codex (GPT-5): 公開Range View監査の比較・同一性区切りを完了。KeyOnly / KeyValueの`elementsEqual`、`lexicographicallyPrecedes`、`==`、`<`へ比較対象・順序・戻り値を追記し、3 Viewの同一性判定を「同一storageかつ同一境界」として要素等価性から区別した。KeyValue / MappedValuesの公開メソッド名`_isdentical(to:)`の綴り不一致は互換性判断が必要なため保留事項へ記録した。Release DocCの`--warnings-as-errors`生成は成功。次はAPI Matrixを基準に、4型の挿入・更新系公開APIを監査する。
- 2026-10-02 16:20 JST Codex (GPT-5): 公開Range View監査の基本操作区切りを完了。KeyOnly / KeyValue / MappedValuesの3 Viewについて、型の役割、境界Index、走査順、`isEmpty` / `count`、`first` / `last`、pop/remove、全削除・条件削除、`isElement` / `isEnd`を対応テストへ照合して文書化した。KeyValueの`keys` / `values`とMappedValuesのsubscript / `swapAt`にはキー順を変更しない契約を追記した。View基本操作34テストが成功し、Release DocCの`--warnings-as-errors`生成も成功。MappedValuesのView外Index検査不足は保留事項へ記録済み。次はViewの比較、同一性判定、および残る公開メンバーを監査する。
- 2026-10-02 16:15 JST Codex (GPT-5): 公開Range View監査を開始。KeyOnly / KeyValue / MappedValuesの3 Viewについて、型の役割、範囲境界の`startIndex` / `endIndex`を文書化し、MappedValuesの要素subscriptと`swapAt`へ引数、事前条件、キー順を変更しない契約を追記した。Release DocCの`--warnings-as-errors`生成は成功。このView監査は未完了で、次は基本状態、走査、先頭末尾、削除、Index有効性を3型横断で照合する。
- 2026-10-02 16:12 JST Codex (GPT-5): 公開コメントドック監査の第4区切りとして、4型のRange/Bound式と範囲eraseを型別`_16_BoundExpressionTests.swift`、Range Viewテスト、Death Test、現行実装へ照合した。公開View/IndexRange/IndexRangeExpression alias、`containsSubrange`、3種の範囲subscript、5種の範囲eraseへ説明、引数、戻り値、範囲の有効性と事前条件を横展開した。逆順・無効範囲は`containsSubrange`で`false`、subscriptでは空Viewへ正規化される一方、eraseは有効な昇順範囲を要求する経路差を明文化した。Bound ExpressionおよびRange View関連147テストが成功し、Release DocCの`--warnings-as-errors`生成も成功。次は3種類の公開Range View自身のコメントドックをTest as Specificationへ照合する。
- 2026-10-02 16:08 JST Codex (GPT-5): 公開コメントドック監査の第3区切りとして、4型のIndex基本操作を型別`_2_BidirectionalCollectionTests.swift`、`_3_IndexSequenceTests.swift`、Death Test、現行実装へ照合した。`startIndex` / `endIndex`、距離、前後・offset移動、limit付き移動、`isElement` / `isEnd`の説明を横展開し、Setに残っていたarray表記と`index(after:)`の説明誤りを修正。さらに4型のoptionalな`firstIndex`が不在時に`endIndex`ではなく`nil`を返すようコメントを訂正した。Index挙動は現行`String`を基準とする方針を規則化し、`EtcTests.testFormIndexLimitedByMatchesString`で、limit到達は`true`、超過時はlimitまで移動して`false`となる一致を確認した。対象テストは成功。Release DocCの`--warnings-as-errors`生成も成功。次はRange/Bound式とViewの公開Index操作を監査する。
- 2026-10-02 16:02 JST Codex (GPT-5): 公開コメントドック監査の第2区切りとして、4型の検索APIを型別`_4_SearchTests.swift`、`_16_BoundExpressionTests.swift`、API Matrix、現行実装へ照合した。`find`、`equalRange`、`contains`、`count(of:)` / `count(forKey:)`へ説明、引数、戻り値、不在時の挙動、unique/multiの差、計算量を追記した。`equalRange`はlower/upper boundによる半開範囲で、不在時は挿入位置の空範囲、multi型では全一致要素を含むことを明文化した。MultiMapの同値キー間の挿入順保証はTest as Specificationから確定できないため、保留事項へ記録した。Release DocCの`--warnings-as-errors`生成は成功。次は公開Index移動・距離・有効性判定とRange/Bound式を監査する。
- 2026-10-02 15:51 JST Codex (GPT-5): 公開コメントドック監査の第1区切りとして、4型の初期化APIを型別`_0_InitializationTests.swift`、API Matrix、現行実装へ照合した。Sequence/Collection/Range、unique keys、重複統合、grouping、array/dictionary literal、minimum capacityの説明、引数、事前条件、重複保持規則、計算量を修正。Setは重複を破棄しMultiSetは保持すること、Dictionaryの`uniqueKeysWithValues`は重複キーを許可しないこと、MultiMapのgroupingは配列へ統合せず全要素を保持すること、Range専用initializerと降順Sequenceのオーバーロード差を明文化した。`swift package --disable-sandbox -c release generate-documentation --target RedBlackTreeCollections --warnings-as-errors`は成功。次は検索・Bounds系の公開コメントドックを監査する。
- 2026-10-02 15:34 JST Codex (GPT-5): ドキュメント横断監査まで完了。Design文書の相対リンクに欠落はなく、利用者向け文書にも現行のCollection/Stridable方針との矛盾は見つからなかった。Overviewから品質方針への導線を追加し、Memory Layoutの関連文書リンクを統一。Test as SpecificationをDesignへ反映する恒久手順も本書へ追加した。CHANGELOGには前回更新後の差分から`OptionalArray1D` / Viewの参照型要素nil代入時の二重解放修正だけを追記し、重複するテスト再編は既存項目へ包含した。OptionalArrayの公開コメントへnil代入の破棄契約と非所有Viewの寿命を追記し、`swift build --disable-sandbox --target OptionalArrayModule`の成功を確認した。通常のsandbox付きbuildは環境のmanifest sandbox制約で開始前に失敗する。
- 2026-10-02 15:34 JST Codex (GPT-5): 原木`Foundamental`テストから確定できる内部契約のDesign反映を完了した。実装への逆照合では、limit付きN歩移動が「ちょうど最終歩でlimitへ着く場合は成功」である点と、Dictionary/MultiMapのCodableが`RedBlackTreePair`を直接encode/decodeする点まで確認した。Fixture固有のkey代用や個別allocationを製品仕様へ混入させず、`TreeNodeOnlyFixture`と`TreeOwnedNodeFixture`の責務・非責務を`Tests/RedBlackTreeFixture/Fixtures.md`へ記録した。今後は実装または原木テストの変更時に、対応するDesign契約も同じ作業で更新する。
- 2026-10-02 14:12 JST Codex (GPT-5): 前回保留だったDocC検証を完了した。ローカルではSwiftPMのsandbox制約を回避するため`--disable-sandbox`が必要だったが、Release構成と`--warnings-as-errors`を含むCI相当の生成は成功した。生成先は`.build/plugins/Swift-DocC/outputs/RedBlackTreeCollections.doccarchive`。追加イニシャライザ、共通操作ガイド、4型および3種類のViewのTopicsとリンクに未解決事項はない。GitHub Actions上の実行結果そのものは、この環境から取得できていない。
