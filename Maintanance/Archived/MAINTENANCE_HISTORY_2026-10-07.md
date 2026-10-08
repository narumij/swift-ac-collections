<!-- CodexとClaudeによるCodexとClaudeのためのメモ -->

# Documentation maintenance notes（2026-10-07アーカイブ前スナップショット）

この文書は、公開ドキュメント、コメントドック、Swift-DocC、およびCHANGELOGを継続的に
整備するための恒久的な判断基準と、現在の文書handoffをまとめる。プロジェクト作業の入口では
ない。作業開始時は`PROGRESS_OVERVIEW.md`のTask Registryを読み、文書taskから参照された場合だけ
本書の該当箇所を読む。

個別タスクの長文結果は、対応する設計文書、監査文書、task文書へ記録する。この文書には
同じ結果を時系列ログとして重複させず、正本への導線、現在の未決事項、再利用する規則だけを
保持する。作業後は`Current handoff`を上書きし、無制限に追記しない。

## Documentation dashboard

最終更新: 2026-10-06 / Codex

### 現在の状態

- C++挙動比較は4型・35件で完了している。現行の証拠正本は
  `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md`。性能測定用`CppBenchmarks`とは分離する。
- failureless public Index PoCはPR #158で統合済み。検証正本は
  `Maintanance/Archived/INDEX_POC_VALIDATION.md`。
- cross-tree Indexテスト監査はCodexの独立再確認を経て完了した。正本は
  `Maintanance/Archived/CROSS_TREE_INDEX_TEST_AUDIT.md`。
- `Design-MemorySafety.md`のdetached Index説明は標準構成の実挙動へ同期済み。
- 公開コメント、DocC、API Matrixの大規模監査は一区切りしているが、Index契約確定後の
  最終同期と、本書の停止条件にある独立確認は残る。
- テストの現在地は`Tests/TESTING.md`、全体進捗は`Maintanance/PROGRESS_OVERVIEW.md`を正とする。
- Claudeの現行権限とhandoffは`Maintanance/CLAUDE_TASK.md`、完了履歴は
  `Maintanance/Archived/CLAUDE_TASK_HISTORY.md`を正とする。

### 文書に関係する未決事項

- Index完了ゲート: `Comparable`、公開Indexと内部`SealError`の分離、完了範囲。
- P10の残り: Index統合前の表現を説明する設計記録のうち、detached説明以外の残存箇所を確認する。
  X1/PoCの準備・検証記録は完了資料としてArchivedへ整理済み。
- Index-range `erase`の空guard: 不要なCoWを避けるために不正範囲の検証を飛ばしてよいか。
- 上記が確定した後の公開コメント、Design、API Matrix、DocC Topicsの最終同期。
- `RedBlackTreeCollections`全体のstrict memory safety採用。現状は未採用で、独立タスクとして扱う。

### 文書管理の運用

- 新しいユーザー要望は、このdashboardまたは該当する正本文書へ日付付きで追加する。
- 完了した個別作業の証拠は正本文書へ置き、本書には状態とリンクだけを残す。
- `CLAUDE_TASK.md`の`Current handoff`は追記型ログにせず、直近の作業再開に必要な最大10項目を
  目安に常に上書きする。正本と重複しない保存価値のある履歴だけを
  `Archived/CLAUDE_TASK_HISTORY.md`へ移す。
- 2026-10-04以前の要望とhandoffは下記の履歴節に残すが、現在のtask queueとして解釈しない。

## Historical user requests and decisions (through 2026-10-04)

以下は当時のユーザー要望と判断の要約である。原文はGit履歴に残る。現行状態は
`Current dashboard`と各正本文書を優先し、この節だけを根拠に作業を自動再開しない。

### 維持する方針

- 公開APIの意味、制約、計算量を、実装を読まなくても把握できる状態を目指す。
- 日英の利用者向け文書、コメントドック、DocC、API Matrixを同期する。
- 公開仕様はTest as Specification、実装、Design文書を照合して確定し、推測で埋めない。
- 1型で不備を見つけた場合は、4型と共有Viewの対応箇所を横断確認する。
- DocCはRelease構成かつ`--warnings-as-errors`で検証する。
- 完了判断はテスト成功やDocC警告0だけに依存せず、独立確認とユーザー確認を含める。

### 完了または正本へ移した要望

- C++挙動比較は4型へ展開済み。挙動比較はルートパッケージ、性能測定は
  `Benchmarks/CppBenchmarks`に分離する。証拠正本は
  `Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md`、作業履歴は
  `Archived/CPP_BEHAVIOR_COMPARISON_TASK.md`。
- 採用準備文書から競争的な「世界最高峰候補」の看板を外し、検証可能な証拠、反証、限界を
  中心とするAdoption Readinessへ再構成済み。
- Debug allocation/lifetime検査の制御とLinux Death Testの実証は完了済み。Linux経路は
  通常CIから外し、明示traitで再実行可能な状態を維持する。
- 4型先頭コメントの編集原稿は
  `Sources/RedBlackTreeCollections/Documentation/Head/`へ配置済み。
- 空storage singletonの条件整理と内部テストは完了済み。現在地は`Tests/TESTING.md`。
- 公開コメントドックの横断監査は一区切り済み。Index契約確定後に最終同期する。
- strict memory safetyの診断、採否、保留理由は
  `StrictMemorySafetyReadiness.md`へ移した。
- AtCoder 2025互換モードの方針は
  `PermutationModule/AtCoder2025CompatibilityPlan.md`を正本とする。

### 残す判断と境界

- `REFACTORING_FROM_ATCODER_2025.md`は、sourceの移動だけでなく、既存テストを活用した判断、
  Fixture分割、`#if false`を段階的に解除した移行過程も証言とGit証拠を分けて記録する。
- Swift標準ライブラリとの比較は前例として使うが、本製品の公開契約を自動的に決める根拠にはしない。
- 公開仕様を確定できない差異、日英どちらが正しいか判断できない差異は保留し、機械的に片方へ揃えない。
- MSVC STL比較は実施せず、完成条件にも含めない。
- 公開ドキュメントの第一担当はCodexとする。Compatibility文書4本の包括監査は独立taskとして
  管理せず、`Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md`または具体的な実装差を
  根拠に、Codexが対象ファイル・項目を限定して扱う。
- Claudeへ公開ドキュメントを委譲する場合は、対象箇所を指定した事実確認、独立レビュー、または
  限定修正とし、4文書全体の監査・改稿へ拡張しない。
- benchmark再開、原木Fixtureの追加portable化、unsafe移行史の追加調査は自動開始しない。

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

- Index関連で文書作業として残るのは、Index完了ゲート、P10の残存記述確認、Index-range `erase`の
  空guard判断、および決定後の公開文書最終同期である。
- cross-tree Index監査とdetached説明の訂正は完了済み。X1/PoCの準備・検証記録もArchivedへ
  整理済みであり、具体的な疑義または再監査の依頼がない限り再開しない。
- C++比較、公開コメントの横断監査、TESTING dashboard同期は完了済み。古いhandoffの
  「次はC++比較」等を現在指示として扱わない。
- 文書だけの変更では通常フルテストを必須としない。コメントドックやコード例を変更した場合は、
  Release DocCまたは対応テストを選ぶ。
- Claudeへ委譲する場合は`CLAUDE_TASK.md`へ対象ファイル、終了条件、編集禁止範囲を記録し、
  完了後にCodexがdiffと正本への反映を確認する。

## Historical handoff (through 2026-10-04)

以下は2026-10-04時点の作業記録である。現在のhandoffではない。

### タスク選定の現在方針（2026-10-04〜）

開発は、機能や検証項目を広く増やす段階から、既存の順序付きコレクションを絞って磨き、
採用判断に耐える信憑性を外部化する段階へ移った。当面のタスクは、次の順で優先する。

1. 再現可能で、比較対象と意味論が揃った正しさ・性能の証拠
2. 有利な主張を反証できる差分テスト、外部参照との比較、失敗例
3. 利用者またはAIが追跡できる生データ、実行条件、既知の限界
4. C++互換性とSwift固有の価値を区別して説明できる検証
5. 上記の信憑性を高める場合に限った、新規機能・ベンチ項目・文書の追加

不利な結果、差がない結果、未計測の軸も成果物として残す。外部プロジェクトは競争相手では
なく、設計判断と適切な用途を明らかにするための参照基準として敬意を持って扱う。
本パッケージはSwift Collectionsの代替を標榜せず、上流のsorted collectionが実験段階にある
間、C++に近い意味論、hint、multi型などを今必要とする利用者への暫定的な中継ぎ・補完と
位置付ける。上流が成熟して同じ要求を満たす場合は、この役割を惰性で守らず再評価する。
予備計測から結論を先取りせず、大規模な横展開の前に、小さな見本の意味論と測定対称性を
レビューする。SortedCollections比較はPhase 3 pilotまでで意図的に停止している。現在の
4型のseed付きC++ compare、採用判断文書への再構成、Debugテストのallocation/lifetime検査
フラグ、Linux Death Testの実証は完了した。Linux Death Testは一度通常CIで成功を確認した後、
ユーザー判断により通常CIから外し、明示traitで再実行可能な状態を保っている。
Compatibility文書4本の一括監査は、Claudeが既存文書を広範囲に改変し始めたためユーザーが
強制停止し、割り当てを撤回した。文書差分は残っておらず、再依頼しない。現在Claudeへの
active assignmentはない。次の作業はユーザーと対象ファイル・変更範囲を合意してから設定する。
候補として残るベンチ再開、原木Fixtureのポータブル化、unsafe移行史の追加調査も自動開始しない。

2026-10-04 Codex: ユーザー合意によりClaudeではなくCodexが限定的に対応した。4つの
Compatibility文書はhint挿入を未提供としていた明白な古い記述だけを現行APIへ修正し、
MultiMap `find`は同値キー群内の個体・rankをC++互換保証に含めない旨を追記した。原木の
MemoryLayoutテストから`_Bucket` / `_BucketAllocator`依存の横断一致検査をRawBuffer側へ移し、
原木側のcoloring用prefixは汎用word幅へ変更した。原木6件、RawBuffer横断1件が成功した。
同じ作業で、公開Compatibility文書とは別に、C++比較テストが実証した範囲だけをまとめる
`CPP_BEHAVIOR_COMPARISON_MATRIX.md`（現`Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md`）を新設した。4型×操作、境界、seed条件、比較した返却事実、
標準上の非保証と未比較項目を一覧化し、今後のC++ compareの正本サマリーとする。結果は
LLVM libc++を正本、GNU libstdc++を参考情報として混同せず記録する。MSVC STL比較は
2026-10-04のユーザー決定により実施せず、完成条件や保留タスクにも含めない。

Claudeなどへ委任した作業の詳細な完了報告、検証結果、変更ファイル、制約、懸念は、Codexが
監査できる指定のタスクmdへ記録し、完了時にユーザーへ直接報告しない。作業がblocked、
安全上の問題を発見した、またはユーザーにしか決められない明示的判断が必要な場合だけ、
判断に必要な詳細を直接報告する。

- 2026-10-03 Codex (GPT-5): `release/AtCoder/2025`からUnsafeTreeV2への移行の要石を保存するため、コンパイル対象外の`UnsafeTreeV2BootstrapTests.swift`を移行途中の旧名`___RedBlackTreeContainerTests_unsafe.swift`へ戻した。確定できた三段階とリファクタリング手法を`Maintanance/REFACTORING_FROM_ATCODER_2025.md`へ記録し、Fixture文書の参照も更新した。
- 2026-10-03 Codex (GPT-5): `RedBlackTreeMappedValuesView`のsubscriptと`swapAt`へ、既存`isElement(at:)`を使ったView範囲検査を追加。同じ木でもView外のIndexは事前条件違反として停止する。検査にキー順序比較を使うため、対象extensionへ既存の`_BaseNode_KeyInterface` / `Comparable`制約を明示し、計算量をO(1)から最悪O(log n)へ更新。MappedValues正常系16件、追加Death Test 3件、RedBlackTreeTests全体が成功。Release DocCも`--warnings-as-errors`で生成成功した。
- 2026-10-03 Codex (GPT-5): ユーザー編集用の4型先頭コメントドック原稿を`Sources/RedBlackTreeCollections/Documentation/Head`へ集約。既存のSet日本語原稿は保持し、残る日英7ファイルを用意した。Set / MultiSet / MultiMapは利用者向け`Documentation`と現行Swiftソース先頭コメントを併置し、単独の利用者向け文書が存在しないDictionaryは現行ソースコメントを編集素材として収録した。ソース本体への反映はユーザー編集後に行う。
- 2026-10-03 00:44 JST Codex (GPT-5): 公開コメント・DocC監査のCodex側最終照合を完了。CustomReflectableはClaudeの独立レビューと追加済みTest as Specificationを確認し、ユーザー了承によりMultiSetの`.set` / MultiMapの`.dictionary`を維持、重複する各出現をラベルなしの子として提供し、子の順序は公開保証しない契約で確定した。API Matrixとの照合で4型の`description` / `debugDescription` / `customMirror`が手動Topicsから漏れていることを発見し、各型ページへ`Inspecting`節として追加。Release DocCを`--warnings-as-errors`で生成し、全12シンボルリンクを含め警告・エラーなく成功した。Codex側の公開API監査は一区切りだが、最上位停止条件に従い、ドキュメント全体の最終完了はClaudeによる公開API・Test as Specification・実装・API Matrix・DocC生成結果の独立した全体確認と、その結果へのユーザー納得まで保留する。
- 2026-10-02 21:18 JST Codex (GPT-5): 公開APIコメントの最終棚卸しを継続。Set / MultiSetの集合演算へ重複数の規則、4型のBound範囲subscriptへView・空範囲・multi型の重複保持、MappedValues Viewの`_isIdentical(to:)`へ同一storageかつ同一境界という契約を補った。公開プロパティには新たなコメント漏れがなく、現行構成の`SubSequence`型aliasへ範囲Viewの順序と重複保持を追記した。SetAlgebra / Protocol関連96テスト、Range View関連34テストが成功し、Release DocCの`--warnings-as-errors`生成も成功。CustomReflectableは標準Set / Dictionaryとの構造比較を終えたが、MultiSet / MultiMapの表示形式と順序契約はClaudeの独立レビューおよびユーザー確認待ち。残る公開宣言候補の大半はDocC非表示の内部hook、互換モード、deprecated経路であり、利用者向けに昇格させずAPI監査対象として扱う。
- 2026-10-02 21:01 JST Codex (GPT-5): Sequence / transformation / protocol conformanceの公開コメント監査を完了。4型の`filter`、`makeIterator`、`sorted`、`reversed`、Dictionary / MultiMapの`mapValues` / `compactMapValues`に引数・戻り値・ソート順・multi型の重複保持を追記。`isTriviallyIdentical(to:)`の誤った呼び出し表記とMultiSetのSet表現流用を修正し、`Equatable` / `Comparable` / `Hashable`の比較単位、辞書式順序、重複数の扱いを明文化。Codableの正常round-tripとmulti型の重複保持を文書化した。一方、外部の非ソート・重複decode入力を検証しない実装とテス不足を発見し、ユーザー記入欄の保留事項へ記録。Sequence / Utility / Transform関連98テスト、Protocol / Value Semantics関連71テスト、Protocol / Codable関連69テストが成功し、Release DocCの`--warnings-as-errors`生成も成功。次はCustomReflectable / descriptionの詳細と、API Matrixから公開宣言の最終掲載漏れを監査する。
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
