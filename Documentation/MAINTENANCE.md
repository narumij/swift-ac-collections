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

- 現在、未完了の優先事項なし

### 相談事項

- DocCの手動Topicsは`API-Matrix.md`と`API-Matrix-View.md`を基準に、検索・挿入・削除・範囲操作などへ広げる。4型の具象型ページだけでなく、共通protocolのDefault ImplementationsやViewへの導線をどこへ置くかは引き続き検討する

### 連絡事項

- この文書のユーザー記入欄を更新する場合は、日付に加えて時刻も記載する
- 最後に作業したモデル名とバージョンを記録する
- 完了済みログを無制限に蓄積しない。恒久的な知見は規則へ移し、`Current handoff`は直近の状況を中心に保つ

### 停止条件

- 公開APIの意味を実装やテストから確定できない場合は、推測で文書化せずユーザーへ確認する
- 日英どちらを正とするか判断できない差異を見つけた場合は、一方へ機械的に合わせず保留事項として記録する

### 保留中の判断・懸念

- API Matrix上の多くの共通APIが、各型のDocCでは`Default Implementations`配下に入る。今回追加した共通操作ガイドから各操作の個別シンボルへ、さらに細かいリンクを追加する必要があるかは公開結果を見て判断する
- 2026-10-02 15:34 JST: `Design-NodeStorage.md`へ記録した「move済みstorageを通常削除で再度deinitializeしない」という所有権契約に、現行実装の既知の未適合がある。`UnsafeTreeV2+KeyValue.swift`のoptional key subscript `_modify`は、既存mapped valueを`.move()`した後、nil代入時に通常の`erase`へ渡すため、参照型Valueで二重破棄になる。詳細と再現経緯は`Tests/TESTING.md`の保留事項を正とする。設計契約は確定しているが、実装修正と回帰テストが完了するまで「全経路で所有権契約を満たす」とは記述しない。

### 完了済みの要望

(ユーザーが確認したら各項目を整理します)

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

- 2026-10-02 15:34 JST Codex (GPT-5): ドキュメント横断監査まで完了。Design文書の相対リンクに欠落はなく、利用者向け文書にも現行のCollection/Stridable方針との矛盾は見つからなかった。Overviewから品質方針への導線を追加し、Memory Layoutの関連文書リンクを統一。Test as SpecificationをDesignへ反映する恒久手順も本書へ追加した。CHANGELOGには前回更新後の差分から`OptionalArray1D` / Viewの参照型要素nil代入時の二重解放修正だけを追記し、重複するテスト再編は既存項目へ包含した。OptionalArrayの公開コメントへnil代入の破棄契約と非所有Viewの寿命を追記し、`swift build --disable-sandbox --target OptionalArrayModule`の成功を確認した。通常のsandbox付きbuildは環境のmanifest sandbox制約で開始前に失敗する。
- 2026-10-02 15:34 JST Codex (GPT-5): 原木`Foundamental`テストから確定できる内部契約のDesign反映を完了した。実装への逆照合では、limit付きN歩移動が「ちょうど最終歩でlimitへ着く場合は成功」である点と、Dictionary/MultiMapのCodableが`RedBlackTreePair`を直接encode/decodeする点まで確認した。Fixture固有のkey代用や個別allocationを製品仕様へ混入させず、`TreeNodeOnlyFixture`と`TreeOwnedNodeFixture`の責務・非責務を`Tests/RedBlackTreeFixture/Fixtures.md`へ記録した。今後は実装または原木テストの変更時に、対応するDesign契約も同じ作業で更新する。
- 2026-10-02 14:12 JST Codex (GPT-5): 前回保留だったDocC検証を完了した。ローカルではSwiftPMのsandbox制約を回避するため`--disable-sandbox`が必要だったが、Release構成と`--warnings-as-errors`を含むCI相当の生成は成功した。生成先は`.build/plugins/Swift-DocC/outputs/RedBlackTreeCollections.doccarchive`。追加イニシャライザ、共通操作ガイド、4型および3種類のViewのTopicsとリンクに未解決事項はない。GitHub Actions上の実行結果そのものは、この環境から取得できていない。
