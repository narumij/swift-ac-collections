# PermutationModule AtCoder 2025互換モード計画

最終更新: 2026-10-09 / Codex

## 実装タスク境界

最初の「現行契約の基準固定」は互換modeから独立した先頭taskとし、その成果を後続するすべての
互換mode taskの入力にする。Task Registryで明示的に再開されるまでは、各taskの凍結を維持する。

| 順序 | 成果単位 | 完了条件 |
| --- | --- | --- |
| 1 | 現行契約の基準固定 | 現行API、通常test、取得済み結果の安定性、旧unsafe APIの非露出を基準として固定 |
| 2 | 互換modeの実施手順決定 | `PERM-004`〜`PERM-010`のcommit境界、検証範囲、警告とtestの扱いをユーザーとCodexで決定 |
| 3 | task依存の再評価 | 決定した手順を基に`PERM-004`〜`PERM-010`と`PERM-013`の順序を見直し、Registryへ反映 |
| 4 | 互換ソースの隔離 | 基準refの実装を専用fileへ置き、通常版と排他的にcompileできる |
| 5 | Package trait設定 | traitありだけが互換版、traitなしは必ず通常版になる |
| 6 | 互換仕様test | 列挙順、重複、safe CoW、unsafe aliasing、境界が基準refどおりに成功する |
| 7 | `AcCollections`再公開検証 | 通常・互換の両modeで期待する公開APIを利用できる |
| 8 | CI分離 | `prepare/compatible/2`統合後、通常版と互換版の機能testを別jobで検証する。性能計測は行わない |
| 9 | 単一file生成・ローカル検証 | 自己完結fileを生成し、ABC328E相当入力で検証する |
| 10 | 文書同期 | 通常APIと互換APIを混同せず、trait、制限、検証方法を記録する |

1は互換modeの実装判断から独立して実施できる。2で実施手順を決め、その結果を入力として3で
依存を再評価してから4へ進む。4以降の正確な順序は3の成果を正本とする。実提出確認はこの実装列に
含めず、引き続きユーザー専任とする。

## 1. 現行契約の基準固定（2026-10-07完了 / Claude Opus 5.5）

通常版の基準は次のtestで固定した。互換modeの検証はユーザー判断で省略した。
2026-10-07のTest as Specification切り替えで、下の2つは
`Tests/PermutationTests/NextPermutationsSequence/`の連番fileへ再編した
（`PermutationRemovedAPITests` → `_0_PublicSurfaceTests`、`PermutationTests` → `_0_`〜`_3_`・`_98_`）。

- `PermutationRemovedAPITests`: 基準版にだけある`unsafePermutations()`と
  `unsafeNextPermutations()`が復活するとcompileが失敗する。一時的に再追加し、個別に
  compile errorになることを確認済み。`COMPATIBLE_ATCODER_2025`では対象外。
  - 2026-10-07の改名で`Permutations`名前空間を廃止したため、その下にあった旧型
    （`All`・`IteratorA`・`SubSequenceA`・`Nexts`等）の検査は外した。トップレベルの型名は
    テスト側の同名宣言が優先されて黙って通るので、この方式では守れない。互換版が通常ビルドへ
    漏れた場合は上の2メソッドも漏れるので、それを漏れの警報とする。
- `PermutationTests`: 列挙順・境界・取得済み結果の安定性・`Sendable`に加え、重複要素と
  非Array入力（`Range`、起点が0でないslice）を追加した。sliceについては、yieldされる結果の
  添字の起点を契約として固定していない（未決）。

## 2. 互換modeの実施手順決定（`PERM-014`）

ユーザーとCodexで`PERM-004`〜`PERM-010`の実施手順を決める。次のClaude案を出発点とし、
このtaskでは実装を始めない。

### 出発点となる`PERM-004`手順案

1. `origin/release/AtCoder/2025`の`Permutations.swift`（456行）と
   `NextPermutationProtocol.swift`（98行）を
   `Sources/PermutationModule/Compatibility/AtCoder2025/`へ無改変でコピーし、それぞれの
   ファイル全体を`#if COMPATIBLE_ATCODER_2025`で囲む。
2. 現行`Permutations.swift`のファイル全体を`#if !COMPATIBLE_ATCODER_2025`で囲む。
3. 「コピーして囲んだだけ」の段階を1 commitにし、現行toolchainに必要な修正は別commitにする。
4. 通常modeはbuildとtestを行う。互換modeはPackage traitがまだ無いため、`Package.swift`を
   一時的に切り替えてPermutationModuleのbuildだけを確認する。

行数は対象refを識別するための参考値であり、実施時にはrefとfile内容を照合する。

### このtaskで決める未決事項

- `R-1`: 基準refはerror 0だが、PermutationModuleのstrict-memory-safety警告が38件ある。
  strict memory safety対応は互換mode作業から外し、後日独立して取り組み直すか。
- `R-2`: 互換modeでは通常版test（`NextPermutationsSequence_1`〜`_98`）と
  `AcCollectionsTests`の`nextPermutations` testがcompileできない。`PERM-004`ではmoduleの
  buildだけを確認し、testのmode別切り分けを`PERM-006`と`PERM-007`へ送ってよいか。

### 決定状況（2026-10-08）

- `R-1`: strict memory safety対応自体を中断し、互換modeの選択肢、検証範囲、完了条件から外す。
  38件の警告は互換modeで解消・受入判定せず、後日独立taskとして前提から再検討する。
- `R-2`: `PERM-004`では互換modeの`PermutationModule` buildだけを確認する。通常版testと
  `AcCollectionsTests`のmode別切り分けは、それぞれ`PERM-006`と`PERM-007`へ送る。

### 確定した実施手順（2026-10-08）

| 成果単位 | commit境界 | 通常modeの検証 | 互換modeの検証 |
| --- | --- | --- | --- |
| 互換ソース隔離 | 基準refの無改変コピーとfile単位の条件コンパイルを1 commit。現行toolchain対応が必要なら別commit | buildと既存test | 一時的なPackage設定による`PermutationModule` buildのみ |
| Package trait | trait、define、既定通常modeを1 commit | traitなしbuildとtest | traitありmodule build |
| 互換仕様test | 基準refの挙動ごとにreview可能なtest commit | 既存testを維持 | 列挙順、重複、safe CoW、unsafe aliasing、境界 |
| `AcCollections`再公開 | mode別の再公開testを1 commit | 現行API | 互換API |
| CI分離 | `prepare/compatible/2`統合後、通常・互換の機能test job分離を1 commit。互換性能計測は追加しない | 通常job | 互換job |
| 単一file生成・検証 | 生成手順とローカル検証を1 commit | 対象外 | ABC328E相当入力。実提出はユーザー専任 |
| 文書同期 | 実装・検証完了後の文書差分を1 commit | 現行APIを記載 | trait、制限、検証方法を区別して記載 |

strict memory safetyの警告件数、注釈、適合判定は上のどの成果単位にも含めない。

完了時には、各taskの成果単位、commit境界、通常・互換modeそれぞれの検証方法と、`R-1`・`R-2`の
結論をこの文書へ記録する。

## 3. task依存の再評価（`PERM-015`）

`PERM-014`で手順が決まった後にだけ、`PERM-004`〜`PERM-010`と`PERM-013`の順序を見直す。
成果はTask Registryのprecedence更新であり、このtaskでは互換modeを実装しない。

必ず確定または棄却する候補は`PERM-004` ← `PERM-013`である。通常版には、まだ性能を計測して
いない`@inline(__always)`全削除（`0ef177d3`）と`next()`の変更（`4eae63f9`）がある。
`PERM-004`で通常版fileを条件コンパイルで囲み、互換fileを追加した後では、性能差にコード配置の
ノイズが混ざり、未計測の変更と互換mode導入の影響を分離しにくい。この候補を採用する場合は、
先に`PERM-013`で通常版の性能基準を取得する。

graph DBのscope-checkはこの組を「辺なし・結合あり」と検出していた。当初は誤検知と判断されたが、
計測結果の帰属という依存を正しく示していた。この訂正と再利用可能な知見は
`AI_GRAPH_SMELL_NOTES.md`を参照する。

### 再評価結果（2026-10-08 / Codex）

候補`PERM-004` ← `PERM-013`を採用する。通常版の未計測変更に対する性能基準は、互換file追加と
条件コンパイルによってコード配置が変わる前に取得する。これにより、既存変更の影響と互換mode導入後の
差を混同しない。

後続の実施順とGateは次のとおり。

| 後続 | 前提 | Gate | 理由 |
| --- | --- | --- | --- |
| 互換ソース隔離 | 性能基準取得 | `START` | 隔離前の通常版を測定対象として固定する |
| 互換ソース隔離 | task依存再評価 | `START` | 確定した順序を反映してから実装を始める |
| Package trait | 互換ソース隔離 | `START` | 隔離済みfileへdefineを接続する |
| 互換仕様test | Package trait | `START` | traitで互換modeを選択可能にしてからtestする |
| `AcCollections`再公開検証 | 互換仕様test | `START` | 互換APIの基準挙動を固定してからfacadeを検証する |
| CI分離 | `prepare/compatible/2`統合 | `START` | 互換準備branchへ統合してから機能testだけを別jobへ接続する |
| 単一file生成 | 再公開検証 | `START` | package内の公開経路を確認後に貼り付け形を検証する |
| 文書同期 | 再公開検証・単一file生成 | `START` | 互換mode完成時点の実装と検証結果を利用方法へ同期する。統合後CIは後から追記する |
| 互換mode親task完了 | 文書同期 | `COMPLETE` | 文書同期までは親taskを完了しない |

単一file生成は再公開検証後に着手する。文書同期は再公開検証と単一file生成の合流点とする。
CI分離は互換mode完成、release gate、`0.5.0` tag、`prepare/compatible/2`統合の後へ延期し、
互換mode親taskと文書同期の完了条件には含めない。

## 4. 互換ソースの隔離（2026-10-08完了）

`origin/release/AtCoder/2025`の`Permutations.swift`と`NextPermutationProtocol.swift`を
`Sources/PermutationModule/Compatibility/AtCoder2025/`へ配置し、file全体を
`#if COMPATIBLE_ATCODER_2025`で囲んだ。現行`Permutations.swift`は反対条件の
`#if !COMPATIBLE_ATCODER_2025`で囲み、両実装を排他的にした。

同一target内の同名basenameを現行toolchainが拒否したため、互換側だけを
`PermutationsAtCoder2025.swift`とした。条件ラッパーと原文2行の行末空白正規化を除く2 fileの内容は
基準refと一致する。
通常構成はXcode build-for-testing成功、active test plan 1412件成功・失敗0。互換構成は2 fileを
`-DCOMPATIBLE_ATCODER_2025 -strict-memory-safety`で`PermutationModule`としてcompileし、error 0を
確認した。strict memory safety警告は既知の対象外として変更していない。

## 5. Package trait設定（2026-10-09完了）

`Package.swift`へ`COMPATIBLE_ATCODER_2025` traitを宣言し、同名のcompile defineへ
`.when(traits:)`で接続した。traitを指定しない場合はdefineが渡らず、通常版が既定になる。

このdefineはPermutationだけでなく、既存のRedBlackTree互換実装と`AcCollections`の条件付き再公開にも
使われている。従来の手編集切替と同じpackage共通の`_settings`へ条件付きdefineを置き、各targetへ
異なる互換状態を渡さない構成とした。

traitなしではXcodeのbuild-for-testingが成功し、active test planは1412件成功・失敗0件だった。
traitありでは次のcommandで`PermutationModule` buildが成功した。

```console
swift build --disable-sandbox --target PermutationModule --traits COMPATIBLE_ATCODER_2025
```

通常の`swift build`は実行環境のmanifest sandbox生成が拒否されたため、SwiftPM自身のsandboxを無効にして
再実行した。互換ソースのstrict-memory-safety警告は既知の対象外として変更していない。

## 6. 互換modeのTest as Specification（2026-10-09完了）

`Tests/PermutationTests/AtCoder2025Compatibility/`へ互換traitでだけ有効な番号付き仕様testを追加した。
基準refの既存testを出発点に、次を5 testで固定した。

- `unsafePermutations()`の全位置順列と、同値要素を位置違いとして重複列挙する挙動
- `nextPermutations()`の辞書順、現在位置以降の列挙、同値要素の重複排除
- safeな`nextPermutations()`で、iteratorを進めた後も保持済み結果が変化しないCoW
- `unsafeNextPermutations()`で、保持済み結果がiteratorのbufferを共有するaliasing
- 空、単一、全要素同値、降順の各入力を最初の1件だけ返す境界

通常版の番号付き仕様testは`!COMPATIBLE_ATCODER_2025`へ限定し、公開型と所有権モデルが異なる2 modeの
契約を同じ実行へ混ぜない。互換構成は対象5件成功・失敗0、traitなしのactive test planは
1412件成功・失敗0だった。

## 7. `AcCollections`再公開検証（2026-10-09完了）

`AcCollectionsTests`は`AcCollections`だけをimportし、traitなしでは現行の
`NextPermutationsSequence`と`nextPermutations()`、traitありでは互換版の
`Permutations.Nexts`、`Permutations.All`、`unsafePermutations()`、`unsafeNextPermutations()`へ
到達できることをcompileと実行で確認する。

通常・互換それぞれの再公開testを個別に実行し、各1件成功・失敗0だった。これにより、
`PermutationModule`単体だけでなくpackageの公開productからも、選択したmodeのAPIが利用できることを
固定した。

## 9. AtCoder単一file生成とローカル検証（2026-10-09完了）

`Utilities/Permutation/GenerateAtCoder2025Permutation.swift`は、互換modeの2 sourceを正本として、
外側の`COMPATIBLE_ATCODER_2025`条件と不要な`Foundation` importだけを除き、標準出力へ連結する。
生成物はrepositoryへ常設しない。sourceの外側条件が期待形と異なる場合は生成を失敗させる。

`Utilities/Permutation/ABC328ELocalValidation.swift`は、ABC328Eと同じ入力形式、制約、
`N - 1`辺の組合せ列挙、union-findによる全域木判定、重み合計のmodulo最小化を行うローカルfixtureである。
生成した555行の単一fileとfixtureをcompileし、公式sample 1を入力して期待値`33`を確認した。
生成fileに互換条件と`Foundation` importが残っていないことも静的に確認した。

実提出は引き続きユーザー専任であり、この完了には含めない。

## 10. 互換mode文書同期（2026-10-09完了）

日英READMEは既存のbranch案内に留め、現行READMEへ互換modeの詳細を混在させない。
`AcCollections`のDocCはmodeごとのPermutation再公開面へ同期した。Permutation品質評価は通常版だけを
評価対象とする境界を維持しながら、互換modeのtrait、旧API、aliasing、仕様test、facade、単一file検証、
strict memory safety警告、統合後CIへの延期が確認済みであることへ更新した。

## 目的

通常ビルドでは、整理済みの現行`PermutationModule`だけを提供する。一方、既存の
AtCoder 2025向けコードを移行するときに限り、`release/AtCoder/2025`時点の公開APIと
観測可能な挙動へコンパイル時に切り替えられるようにする。

互換APIを通常ビルドへ再追加する計画ではない。`swift-algorithms`と重複するAPIや
unsafeな結果共有を、現行APIとして再推奨もしない。

## 確認した基準点

- 基準ref: `remotes/origin/release/AtCoder/2025`
- 基準ソース: `Sources/PermutationModule/Permutations.swift`
- 共有しない（2026-10-07変更）: 基準refの`NextPermutationProtocol.swift`。通常版はこのprotocolを
  廃止し、アルゴリズムを`Permutations.swift`の`Buffer`拡張へまとめた（ファイル頭の長いヘッダーは削除、関数ごとのswift-algorithms出典コメントは維持）。互換版は基準refの
  protocolファイルを互換ディレクトリへ自分で持つ。
- 型名の差（2026-10-07）: 通常版は`Permutations<C>.Nexts`/`IteratorN`/`SubSequenceN`を
  `NextPermutationsSequence<Base>`/`.Iterator`/`.Permutation`へ改名し、`Permutations`名前空間を
  廃止した。互換版は基準refの旧名をそのまま持つ。
- 切替名: `COMPATIBLE_ATCODER_2025`。`Package.swift`の同名traitがpackage共通のcompile defineへ
  接続され、Permutationを含むAtCoder 2025互換実装を切り替える。

基準版にだけ存在する公開表面は次のとおり。

- `unsafeNextPermutations()`
- `unsafePermutations()`
- `Permutations.All`
- `Permutations.IteratorA`
- `Permutations.SubSequenceA`
- `Permutations.Nexts.init(safe:)` / `init(unsafe:)`
- safe/unsafeを切り替える各iteratorの内部経路

`nextPermutations()`自体は両版に存在する。現行版は常にCoWを行い、取得済み結果を
保持しても値が変化しない。基準版にはsafe/unsafeの選択肢があり、unsafe経路では
結果が内部bufferを共有する。この差は互換テストで固定し、通常版の仕様へ混ぜない。

## 採用する構成

同じ`PermutationModule`ターゲット内で、`COMPATIBLE_ATCODER_2025`により実装を
排他的に選択する。

```text
Sources/PermutationModule/
├── Permutations.swift                            # 現行版のみ（アルゴリズム含む）
└── Compatibility/AtCoder2025/
    ├── NextPermutationProtocol.swift             # 互換版のみ
    └── PermutationsAtCoder2025.swift             # 互換版のみ
```

- 現行ファイル全体を`#if !COMPATIBLE_ATCODER_2025`で囲む。
- 互換ファイル全体を`#if COMPATIBLE_ATCODER_2025`で囲む。
- 同じ宣言へ細かな`#if`を散らさない。2版の公開表面と所有権モデルが大きく異なるため、
  ファイル単位で分けた方が差分を監査しやすい。
- 別ターゲット名にはしない。既存コードの`import PermutationModule`を変更せずに
  コンパイルできることが互換モードの目的だからである。
- 通常版から削除したunsafe APIをdeprecated aliasとして再公開しない。

## Package設定

`COMPATIBLE_ATCODER_2025`をPackage traitとして宣言し、既存の手編集コメント切替を
trait条件のdefineへ置き換える。traitを指定しない既定ビルドは必ず現行版とする。

互換defineは、互換性を検証する必要がある既存ターゲットへだけ渡す。新しい通常APIが
誤って互換defineへ依存しないよう、可能なら全ターゲット共通の`_settings`から分離する。

AtCoderへ貼り付ける単一ファイルの生成はSwiftPM traitとは別問題である。生成元を
互換ファイルへ固定し、生成物自体はリポジトリへ常設しない。

## 実装段階

### 1. 基準版の隔離コピー

1. 基準refの`Permutations.swift`を互換ファイルの出発点にする。
2. 公開宣言、列挙順、重複値、safe/unsafeのaliasing挙動を変えない。
3. 現行toolchainでのコンパイルに必要な構文修正は、公開挙動と分けて記録する。
4. strict-memory-safety注釈や適合判定はこの互換mode作業で扱わない。診断を消す目的だけでunsafe経路へ
   注釈を追加しない。

### 2. モード別Test as Specification

- 通常モードでは現在の`PermutationTests`をそのまま実行し、削除済みAPIが復活して
  いないこと、取得済み`NextPermutationsSequence.Permutation`が安定することを維持する。
- 互換モードでは基準refのテストを復元し、次を明示的に固定する。
  - `unsafePermutations()`の全順列列挙順と重複の見え方
  - `nextPermutations()`が現在位置以降だけを列挙すること
  - safe結果のCoWと、unsafe結果を保持した場合のaliasing
  - 空、単一、降順、同値要素の境界
- 通常版の`Sendable`コンパイル時テストは互換モードへ自動適用しない。互換版のunsafe
  iteratorを`@unchecked Sendable`にして通すことは禁止する。

### 3. 再公開と貼り付け検証

1. 通常・互換の両モードで`AcCollections`から期待するAPIが再公開されることを確認する。
2. 自己完結したAtCoder用単一ファイルを互換版から生成し、ローカルでABC328E相当の
   入力を検証する。
3. 実提出は外部操作なのでユーザーが行い、提出日時、Swift版、結果だけを記録する。

## 完了条件

- traitなしの通常ビルドで、削除済みunsafe/All APIが公開されない。
- traitありの互換ビルドで、基準版の公開テストがソース変更なしでコンパイル・成功する。
- 両モードで`AcCollections`経由の利用を検証する。
- 通常版と互換版の仕様testを条件で分離する。CIの別job化は`prepare/compatible/2`統合後に行う。
- 互換版の存在を理由に、現行仕様書へunsafe APIを現役APIとして掲載しない。

## 完了後に残すこと

- `prepare/compatible/2`統合後、通常版と互換版の機能testをCIの別jobにする。互換性能計測は行わない。
- ABC328Eへの外部提出はユーザー専任とし、agentは着手・代行・催促しない。
