# PermutationModule 品質評価（ISO/IEC 25000シリーズ観点）

> 状態: 初版レビュー完了（2026-10-08 / Codex）。利用者向け文書作業と1.0判断の入力とする。
> 評価時点: `d8734a65`（branch `develop/misc/50`）。2026-10-07夜に`c64116e0`時点の事実へ更新（`PERM-016`）。
> 赤黒木（RedBlackTreeCollections）の品質ゲートは`Sources/RedBlackTreeCollections/Documentation/Quality-Checklist.md`
> （`QUALITY-001`）であり、本書はPermutationModuleだけを対象とする。

## 1. 位置づけ

- 品質モデルはISO/IEC 25010:2023の製品品質9特性を使う。利用時の品質（ISO/IEC 25019）は
  §4にだけ簡単に触れる。
- 評価の進め方はISO/IEC 25040の流れ（目的 → 品質要求 → 評価の設計 → 実施 → 結論）に
  ゆるく合わせる。測定量（ISO/IEC 25023）の厳密な適用はしない。
- 仕様の正本はTest as Specification（`Tests/PermutationTests/NextPermutationsSequence/`の
  連番file）である。本書は仕様を再記述しない。各判定の根拠としてtestやfileを指すだけにする。
- 判定は次の4段階とする。
  - 満たす: 根拠となるtestや確認がある。
  - 部分: 根拠はあるが、構成・環境・範囲に欠けがある。
  - 未評価: 根拠がまだない。
  - 対象外: このmoduleの性質上、評価しない。

## 2. 評価の目的と対象

- 目的: 汎用ライブラリの部品として公開してよい品質かを、1.0判断の前に把握する。
- 対象: `Sources/PermutationModule/Permutations.swift`の公開表面
  （`Collection.nextPermutations()`、`NextPermutationsSequence`、`.Iterator`、`.Permutation`）。
- 対象外: AtCoder 2025互換mode（`PERM-004`〜`PERM-010`、未実装）。実装後に別途評価する。
- 前提（2026-10-07、ユーザー判断）: Swiftの標準protocolの意味論・契約（例: `Collection.count`が走査できる
  要素数と一致すること、`Comparable`が全順序であること）は信じる。契約に違反する適合型への防御は品質要求に含めない。
  利用者が普通に踏みうる誤用（範囲外の添字など）への`precondition`とは区別する。

## 3. 製品品質（ISO/IEC 25010:2023）

### 3.1 機能適合性（Functional suitability）

| 副特性 | 判定 | 根拠 |
| --- | --- | --- |
| 機能完全性 | 満たす | 公開APIは`nextPermutations()`の1経路だけ。全順列列挙はswift-algorithmsへ委ねる設計で、削除済みAPIの非露出は`_0_PublicSurfaceTests`がcompile時に固定 |
| 機能正確性 | 部分 | 列挙順・境界・重複・入力型は`_1_EnumerationTests`、値の安定性は`_2_ValueSemanticsTests`。期待値は手書きで、C++ `std::next_permutation`との差分比較（`CppBehaviorReference`）はない |
| 機能適切性 | 満たす | C++の`next_permutation`相当という目的に対し、APIはそれだけを提供する |

### 3.2 性能効率性（Performance efficiency）

| 副特性 | 判定 | 根拠 |
| --- | --- | --- |
| 時間効率性 | 部分 | 1ステップ最悪O(n)はソースのドキュメントコメントでの約束で、testはない。`Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift`に5件の計測がある |
| 資源効率性 | 部分 | 入力を1回bufferへコピーする。結果を保持しなければ追加のコピーは起きないこと、最後の結果を保持したまま終端に達しても終わりを知るためだけのコピーは起きないこと（`4eae63f9`）を、`_98_InternalTests`が`DEBUG`下でだけ確認 |
| 容量 | 対象外 | 列挙数は入力に対して階乗的に増えるが、それは列挙の性質であり、このmoduleの上限ではない |

懸念: CIの性能比較（`.github/workflows/swift.yml`のperformance job）が使う`Benchmarks/Libraries/CI.json`に、
Permutationの計測は入っていない。2026-10-07の`@inline(__always)`27件の全削除（`0ef177d3`）の影響は、
どこでも測られていない。`next()`が共有中の終端でコピーしないようにした変更（`4eae63f9`）も未計測で、`PERM-013`で確かめる。

2026-10-08のCI追加試行では、既存5計測をそのまま`CI.json`へ列挙できないことが判明した。performance
jobはPR側の同じ`CI.json`をbase / HEADの双方へ使うため、base側にも5件の表題は存在する。一方、library
schemaは計測ごとのsize範囲を指定できず、job全体の`--max-size 64k`が適用される。end-to-end計測は
`size <= 10`をpreconditionとするため、追加すると10を超える入力でprocessが停止する。残る4件には同じ
上限制約はない。したがって、5件を比較対象に保つ実行構成を別途確定してからCI設定を変更する。

追加調査では、二つのlibraryを異なる最大sizeで同じ結果fileへ順次実行できることを確認した。1本目で
subscript 4件を現行の`--max-size 64k`・`--mode replace-all`で測定し、2本目でend-to-end 1件を
`--max-size 10`・`--mode append`により追記する。base側にもPR側の二つのlibrary定義をcopyすれば、
既存sourceのままbase / HEADを同条件で比較でき、後段の`results compare`も変更不要である。

代案としてbenchmark sourceの`add`へ`maxSize: 10`を指定できるが、base側sourceにはその変更がない
最初のPRだけ停止するため採用候補として劣る。別結果fileを`results merge`する案にも、同じfileへ直接
追記する方式を上回る利点はない。推奨は二つのlibraryと同一結果fileへの追記である。

2026-10-08、ユーザー判断により推奨案を採用した。subscript 4件を既存`CI.json`・最大64kで測り、
end-to-end 1件を小size用library・最大10で同じ結果fileへ追記する。base / HEADの両方にPR側の二つの
library定義を用い、benchmark sourceと既存の比較・回帰判定は変更しない。

### 3.3 互換性（Compatibility）

| 副特性 | 判定 | 根拠 |
| --- | --- | --- |
| 共存性 | 満たす | 通常版はswift-algorithms 1.2.1と同時importし、修飾なしで両APIを解決するtestを`_4_CoexistenceTests`に追加済み（`0ff5fd84`、`PERM-018`）。未実装で凍結中の互換modeは現行通常版の評価へ含めない |
| 相互運用性 | 満たす | `Sequence`・`IteratorProtocol`・`RandomAccessCollection`へ適合し、標準の`map`や`Array(_:)`で使える（`_1_`〜`_3_`）。`Permutation`は`Equatable`・`Hashable`（要素が`Hashable`のとき）で、`Set`や辞書のキーにできる（`_3_`）。結果の添字は入力に関係なく0始まりの`Int`（`_3_`の`testIndicesStartAtZeroForAnySource`）。`AcCollections`経由の再公開は`AcCollectionsTests.test_importAcCollections_exposesNextPermutations` |

### 3.4 インタラクション能力（Interaction capability。旧: 使用性）

ライブラリでは、利用者＝API利用者として読む。

| 副特性 | 判定 | 根拠 |
| --- | --- | --- |
| 適切度認識性 | 部分 | ドキュメントコメントに、全順列ではないこと、swift-algorithmsとの使い分けを記載。利用者向けの文書（赤黒木の`Documentation/*.md`に相当するもの）はない |
| 習得性 | 部分 | 公開型を`NextPermutationsSequence` / `.Iterator` / `.Permutation`へ改名した（`169401a0`）。commitに記録された理由は、`N`接尾辞が削除済みの`All`系との区別にしか使われていなかったことと、`SubSequenceN`が`Collection.SubSequence`と紛らわしいこと。使用例はない |
| 運用操作性 | 満たす | 入口は1つ。Array以外や添字がIntでないCollectionも受け付ける（`_1_`の`testAcceptsNonIntIndexedSources`） |
| ユーザーエラー防止性 | 満たす | 利用者は直接初期化できない（`_0_`がcompile時に固定）。範囲外の添字は`precondition`で停止（`_99_DeathTests`） |
| 自己記述性 | 部分 | 公開型の説明はドキュメントコメントのみ。DocCカタログはない。結果は`print`でArrayと同じ形に表示される（`_3_`の`testDescriptionLooksLikeArray`） |

### 3.5 信頼性（Reliability）

| 副特性 | 判定 | 根拠 |
| --- | --- | --- |
| 成熟性 | 部分 | Test as Specificationを`swift test`のDebug・Releaseで実行（CIはLinux）。テストできない約束は少ない |
| 可用性 | 対象外 | 常駐するサービスではない |
| 障害許容性 | 対象外 | 誤用は`precondition`で停止させる方針で、継続動作は目指さない |
| 回復性 | 対象外 | 状態を永続化しない |

懸念: 2026-10-07、Swift 6.4の`-O`で、コピーした変数をクロージャ内で変更すると
`isKnownUniquelyReferenced`がコピーを見落とし、共有bufferが直接書き換わる現象を見つけた。
ライブラリに依存しない最小再現で起きる。`_2_ValueSemanticsTests.testIteratorCopiesAdvanceIndependently`は
assertionの外で`next()`を呼んでこれを避けている。ユーザー判断で、深追いは1.0直前まで保留。

### 3.6 セキュリティ（Security）

ここではメモリ安全性として読む。

| 副特性 | 判定 | 根拠 |
| --- | --- | --- |
| 完全性 | 部分 | target全体に`.strictMemorySafety()`を恒久適用し、unsafe操作は所有境界ごとのscoped `unsafe`に限定（`Maintanance/StrictMemorySafetyReadiness.md`）。添字の範囲検査はDebug・Releaseで有効。`-Ounchecked`では省略されうる（ソースのドキュメントコメントに明記）。入力のbufferへのコピーは`Collection.count`の契約を信じている（§2の前提。`count`を偽る適合型では範囲外へ書きうることを2026-10-07に確認したうえで、防御しないと判断）。bufferの`deinit`がheaderを手動で破棄して二重破棄になっていた潜在不具合を修正（`4eae63f9`）。headerが参照型を持つと落ちることをtestで確かめてから直した |
| 機密性・否認防止性・責任追跡性・真正性・耐性 | 対象外 | 秘密情報や外部入力の境界を持たない |

懸念: Death Testは、macOSでは既定で、Linuxではtrait指定時だけ有効になる。CI（Linux）では実行されていない。
Releaseでの停止は2026-10-03にローカルのmacOSで5件とも確認したのみ（`Maintanance/PermutationModule/ProductReadinessAssessment.md:152`）。

### 3.7 保守性（Maintainability）

| 副特性 | 判定 | 根拠 |
| --- | --- | --- |
| モジュール性 | 満たす | 1 file、空行・コメントを除いて254行（`c64116e0`時点。`4a75b9f8`時点の213行から、`Equatable`・`Hashable`と`DEBUG`限定の検査用memberが増えた）。基準ref（`release/AtCoder/2025`）の約446行から縮小 |
| 再利用性 | 満たす | 外部依存なし |
| 解析性 | 満たす | 仕様は連番のTest as Specificationだけにあり、文書との二重管理はない（`5efc1a9c`）。`.task-graphs`の`spec-gaps`で公開APIの仕様test参照を確認（0件） |
| 修正性 | 満たす | 死んだ汎用化（使われない`upperBound`・`capacity`・二重の型パラメータ）を除去済み（`4a75b9f8`）。iteratorの状態は3値のenumで、ありえない組み合わせを持たない（`c204dd9f`）。次の並びを探す走査は`hasNextPermutation`と`nextPermutation()`で共有する（`2495b095`） |
| 試験性 | 満たす | 「存在しないこと」の約束は、同名宣言を置いてcompile errorで検出する方式。実際にAPIを戻して検出を確認済み。testのための検査用member（`_copyCount`、headerの破棄を数えるprobe）は`#if DEBUG`の`package`に限り、Releaseの公開APIへ出さない（`2495b095`、`c64116e0`） |

懸念: AtCoder 2025互換modeを実装すると、基準refの実装が別fileとして戻る。通常版と排他的にcompileされることの
検証（`PERM-005`〜`PERM-008`）が済むまでは、この判定は通常版だけについてのものである。

### 3.8 柔軟性（Flexibility。旧: 移植性）

| 副特性 | 判定 | 根拠 |
| --- | --- | --- |
| 適応性 | 満たす | 入力は任意の`Collection`（要素は`Comparable`）。2026-10-07に`Index == Int`制約を除去 |
| 拡張性 | 対象外 | 利用者が拡張する設計ではない |
| 設置性 | 満たす | SwiftPMのtargetとして利用。`swift-tools-version: 6.2`、`platforms: [.macOS(.v15)]` |
| 置換性 | 部分 | AtCoder 2025版から移行する利用者向けの互換modeは未実装（`PERM-004`以降） |

懸念: AtCoderの判定環境は`import AcCollections`に依存できない。単一fileでの提出確認（`PERM-002`、ユーザー専任）と
その生成（`PERM-009`）は未実施。

### 3.9 安全性（Safety）

| 副特性 | 判定 | 根拠 |
| --- | --- | --- |
| 全副特性 | 対象外 | 人命・財産・環境に直接影響する用途を想定しない。誤用時に停止する性質は§3.4・§3.6で扱う |

## 4. 利用時の品質（ISO/IEC 25019）

主な利用文脈はAtCoderでの競技プログラミング（ABC328Eが存在理由）。有効性・効率性の実地確認は、
`PERM-002`（ユーザーによる実提出）に委ねる。未評価。

## 5. 判定の要約

- 満たす: 機能完全性、機能適切性、共存性、相互運用性、運用操作性、ユーザーエラー防止性、保守性の全副特性、適応性、設置性
- 部分: 機能正確性、時間効率性、資源効率性、適切度認識性、習得性、自己記述性、成熟性、完全性、置換性
- 未評価: 利用時の品質

## 6. Codexへのレビュー依頼

- (R-1) 25010:2023の特性・副特性の読み替え（ライブラリでの「インタラクション能力」「セキュリティ」の解釈）は妥当か。
- (R-2) 「部分」としたもののうち、1.0の前に「満たす」へ上げるべきものはどれか。Claudeの見立ては次の3つ。
  - CIの性能比較にPermutationの計測を加える（§3.2）
  - C++ `std::next_permutation`との差分比較を加える（§3.1）
  - Linux CIでDeath Testを有効にする（§3.6）
- (R-3) 利用者向け文書（§3.4）を、赤黒木と同じ形で用意するか。用意しない場合、ドキュメントコメントだけで足りるとする根拠をどう書くか。
- (R-4) 事実の誤り、根拠の指し違い（commit・file・test名）がないか。

### R-4限定のClaude assignment（2026-10-08）

品質評価本文に現れるcommit、file、test名、行数・件数、CI・構成の参照を現行repositoryへ機械的に
照合する。成果物は、参照箇所、記載内容、照合先、`一致` / `不一致` / `履歴として一致` / `未確認`の
表とする。名称変更や移動がある場合は旧・現行の対応を記録する。

品質特性の評価、1.0前に必要な改善、利用者向け文書形式、性能基準を判断せず、本文の評価語も
変更しない。不一致または新しい判断点を見つけた場合は根拠を記録して停止し、source、test、CI、
他の文書を修正しない。CodexがR-1〜R-3の解釈とともに検収する。

### PERM-024 根拠参照の照合結果

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。HEAD `e169c24e`に対して照合した。`L<n>`は本書の行。評価語は変更していない。

| 参照箇所 | 記載内容 | 照合先 | 結果 |
| --- | --- | --- | --- |
| L4 | 評価時点`d8734a65`（`develop/misc/50`）、`c64116e0`時点へ更新（`PERM-016`） | `git show`、Registry | 一致（両commitとも2026-10-07。`PERM-016` DONE） |
| L5 | 赤黒木の品質ゲートは`Quality-Checklist.md`（`QUALITY-001`） | file、Registry | 一致（file存在、`QUALITY-001` FROZEN） |
| L14 | 仕様の正本は`Tests/PermutationTests/NextPermutationsSequence/`の連番file | ディレクトリ | 一致（`_0_`〜`_4_`、`_98_`、`_99_`） |
| L27 | 互換modeは`PERM-004`〜`PERM-010`、未実装 | Registry | 一致（すべてFROZEN） |
| L38 | 削除済みAPIの非露出は`_0_PublicSurfaceTests`がcompile時に固定 | `NextPermutationsSequence_0_PublicSurfaceTests.swift:44-76` | 一致（対象は2メソッドだけ。旧型名は守れないと同file 16-19行目） |
| L39 | `_1_EnumerationTests`、`_2_ValueSemanticsTests`。`CppBehaviorReference`との差分比較はない | test file、`Sources/CppBehaviorReference`・`Tests/CppBehaviorReferenceTests` | 一致（どちらにも`permutation`の語が無い） |
| L46 | `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift`に5件の計測 | 同file | 一致（`self.add(`が5件。表題は旧名`Permutations.SubSequenceN`のまま。旧名維持は`169401a0`の方針） |
| L47 | 終端で不要なcopyをしない（`4eae63f9`）。`_98_InternalTests`が`DEBUG`下で確認 | commit、`_98_InternalTests.swift:8,25,67` | 一致 |
| L50 | CIの性能比較が使う`Benchmarks/Libraries/CI.json`にPermutationは無い | `.github/workflows/swift.yml:102-`（performance job）、`CI.json` | 一致（`CI.json`に`perm`の語が無い） |
| L51 | `@inline(__always)` 27件の全削除（`0ef177d3`） | `git show 0ef177d3 -- Sources` | 一致（削除行27、追加0） |
| L52 | `4eae63f9`は未計測、`PERM-013`で確かめる | Registry | 一致（`PERM-013` FROZEN） |
| L58 | swift-algorithms 1.2.1の型名`PermutationsSequence`・`UniquePermutationsSequence` | `Package.resolved`、`.build/checkouts/swift-algorithms/Sources/Algorithms/Permutations.swift:79,404` | 一致 |
| L58 | **両方をimportした状態のtestはない** | `NextPermutationsSequence_4_CoexistenceTests.swift`（`0ff5fd84`、Registry `PERM-018` DONE） | **不一致**: 2026-10-07に、両moduleを同時importして修飾なしで解決するtestが追加されている。本書の更新（`PERM-016`、`127a0d5b`）は`0ff5fd84`より前 |
| L59 | `testIndicesStartAtZeroForAnySource`、`AcCollectionsTests.test_importAcCollections_exposesNextPermutations` | `_3_PermutationCollectionTests.swift:24`、`Tests/AcCollectionsTests/AcCollectionsTests.swift:72` | 一致 |
| L68 | 命名はswift-algorithmsの`PermutationsSequence<Base>`に合わせた（`169401a0`） | `169401a0`のcommit本文 | 未確認（commit本文が記録する理由は「`N`は削除済みの`All`系との区別だけ」「`SubSequenceN`は`Collection.SubSequence`と紛らわしい」。swift-algorithmsへ合わせたという記録は見つからない） |
| L69 | `testAcceptsNonIntIndexedSources` | `_1_EnumerationTests.swift:81` | 一致 |
| L70 | 直接初期化できないことを`_0_`が固定、範囲外は`_99_DeathTests` | `_0_PublicSurfaceTests.swift:70`、`_99_DeathTests.swift` | 一致 |
| L71 | `testDescriptionLooksLikeArray` | `_3_PermutationCollectionTests.swift:48` | 一致 |
| L77 | `swift test`をDebug・Releaseで実行（CIはLinux） | `swift.yml:79-100`（`ubuntu-24.04`、`-c debug` / `-c release`） | 一致 |
| L84 | `testIteratorCopiesAdvanceIndependently`はassertionの外で`next()`を呼ぶ | `_2_ValueSemanticsTests.swift:34-47` | 一致 |
| L85 | 深追いは1.0直前まで保留（ユーザー判断） | `Permutations.swift:71-73`のTODO | 履歴として一致（sourceのTODOに「1.0直前に確認」とある。ユーザー判断そのものの記録は今回見ていない） |
| L93 | target全体に`.strictMemorySafety()`を恒久適用 | `Package.swift:311-320` | 一致 |
| L93 | header二重破棄の修正（`4eae63f9`） | commit、`_98_InternalTests.swift:14` | 一致 |
| L96 | Death Testは、macOSでは既定、Linuxではtrait指定時だけ。CI（Linux）では実行されない | `Package.swift:82,85`、`swift.yml`（`ENABLE_DEATH_TESTS`の指定なし） | 一致 |
| L97 | Releaseでの停止は2026-10-07にローカルmacOSで5件とも確認 | `PermutationModule/ProductReadinessAssessment.md:152` | 未確認（見つかった記録は、同じ5件をDebug / ReleaseともSIGTRAPで確認した2026-10-03の節だけ。10-07の確認記録は見つからない） |
| L103 | 空行・コメントを除いて254行（`c64116e0`）、`4a75b9f8`時点は213行、基準refは約446行 | `git show <ref>:…/Permutations.swift`で空行と`//`行を除いて数えた | 一致（254 / 213。HEADも254）。基準refは`Permutations.swift`の391行と`NextPermutationProtocol.swift`の55行を足すと446で、2 file合計としてなら一致。1 fileだけだと391行（総行数456） |
| L105 | 二重管理なし（`5efc1a9c`）。`spec-gaps`で公開APIの仕様test参照を確認（0件） | commit、`.task-graphs/claude-tg.sh spec-gaps` | 一致（今回の実行も未参照0件。ただしcode graphは`b87c8428`時点のまま） |
| L106 | `4a75b9f8`、`c204dd9f`、走査の共有（`2495b095`） | commit、`Permutations.swift:306-319` | 一致（`hasNextPermutation`と`nextPermutation()`が`lastAscentIndex`を共有） |
| L107 | APIを戻して検出を確認済み。検査用memberは`#if DEBUG`の`package`（`2495b095`、`c64116e0`） | `AtCoder2025CompatibilityPlan.md:34-36`、`Permutations.swift:119-137,191-193` | 一致（戻して確認したのは履歴として記録あり） |
| L116 | 2026-10-07に`Index == Int`制約を除去 | `4a75b9f8` | 一致 |
| L118 | `swift-tools-version: 6.2`、`platforms: [.macOS(.v15)]` | `Package.swift:1,119-120` | 一致 |
| L119、L121 | 互換modeは`PERM-004`以降、`PERM-002`はユーザー専任、`PERM-009`は未実施 | Registry | 一致（`PERM-002` USER_ONLY、`PERM-009` FROZEN） |

停止事項: L58の不一致1件。訂正するか、共存性の判定に影響するかはCodexが判断する（本文と評価語は変更していない）。

Codex acceptance（2026-10-08）: 参照箇所と現物の対応、結果分類、停止条件を満たすため受け入れた。
共存test追加後の事実、不裏付けの命名理由、Release確認日の3点は事実補正候補として別taskへ渡す。
品質特性の評価変更とR-1〜R-3の判断はCodexのreviewに残す。

### PERM-025 事実参照補正 assignment（2026-10-08）

担当: Claude。本文の次の3点だけを、PERM-024の照合結果に合わせる。

- swift-algorithmsとの同時import testが追加済みである事実を反映する。
- 改名理由を`169401a0`に実際に記録された理由へ限定し、記録のない「swift-algorithmsへ合わせた」を除く。
- Release Death Testのローカル確認日を、根拠が存在する2026-10-03へ直す。2026-10-07の確認を推定しない。

対象箇所の品質評価（`満たす` / `部分`等）、1.0前の改善候補、R-1〜R-3、性能・文書方針は変更しない。
3点以外の本文、source、test、CI、他文書も変更しない。事実補正が評価語と矛盾する場合は評価を自分で
変更せず、その位置を報告して停止する。

### PERM-025 実施結果

2026-10-08 / Claude Opus 5.5。§3.3の共存性、§3.4の習得性、§3.6の懸念の3か所だけを直した。評価語は変更していない。

停止事項（評価語との関係）: 共存性の「部分」は、補正前の本文では「両方をimportした状態のtestはない」が唯一の欠けとして
読めた。補正後の根拠欄には欠けが書かれていないので、「部分」の理由が本文から読み取れなくなった。評価を変えるか、
別の欠けを根拠に書くかはCodexが判断する。習得性の「部分」は「使用例はない」が残るので、根拠と矛盾しない。

Codex acceptance（2026-10-08）: 指定された3点だけが照合結果へ同期され、評価語は維持されたため
受け入れた。共存性の評価はR-1〜R-4 reviewでCodexが扱い、`PERM-025`を完了とする。

### PERM-026 共存性evidence gap assignment（2026-10-08）

担当: Claude。通常版Permutationとswift-algorithmsの同時import、`AcCollections`経由の再公開、
凍結中の互換modeを混同せず、共存性について既存testで検証済みの範囲と未検証の範囲を表にする。
対象、構成、根拠test、確認できる事実、未検証事項を記録する。

`満たす` / `部分`の評価、必要な追加test、互換modeの再開、文書境界を決めない。source、test、CI、
本文の評価語を変更しない。新しいdefectまたは判断点を見つけた場合は根拠を記録して停止する。
成果物は本節の直後へ追記し、Codexが共存性の評価を決める入力にする。

### PERM-026 共存性の検証範囲

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。HEAD `d66bf0f1`。既存testと`Package.swift`の読み取りだけで、test・構成は変更していない。

| 対象 | 構成 | 根拠test | 確認できる事実 | 未検証事項 |
| --- | --- | --- | --- | --- |
| 通常版`PermutationModule`とswift-algorithmsの同時import | 通常mode。`PermutationTests`は`Algorithms`へ依存（`Package.swift:322-324`）。CIはLinuxのDebug / Release（`swift.yml:79-100`） | `NextPermutationsSequence_4_CoexistenceTests.swift:16,23`（`0ff5fd84`） | `nextPermutations()`と`permutations()`が修飾なしで解決する。型注釈で`NextPermutationsSequence<[Int]>`と`PermutationsSequence<[Int]>`を書ける。後続だけと全順列の違い | `uniquePermutations()` / `UniquePermutationsSequence`と、`permutations(ofCount:)`・範囲版overloadは参照していない。名前が異なるので衝突の可能性は低いが、testでは固定されていない。swift-algorithmsの版は1.2.1（`Package.resolved`）だけ |
| swift-algorithms側の`nextPermutation` | 同上 | なし | swift-algorithms 1.2.1の`nextPermutation(upperBound:)`は`internal`（`.build/checkouts/swift-algorithms/Sources/Algorithms/Permutations.swift:32`）なので、公開名としては衝突しない | upstreamが将来これを公開した場合の衝突は、F4では検出されない（現行のF4は`nextPermutations`（複数形）と`permutations`しか呼ばない） |
| `AcCollections`経由の再公開 | 通常mode。`AcCollections`は`PermutationModule`を無条件に`@_exported`（`Sources/AcCollections/AcCollections.swift:2`）。`AcCollectionsTests`は`Algorithms`へ依存しない（`Package.swift:198-202`） | `Tests/AcCollectionsTests/AcCollectionsTests.swift:72`（`test_importAcCollections_exposesNextPermutations`） | `import AcCollections`だけで`nextPermutations()`を呼べ、結果が`[[1, 2], [2, 1]]` | `import AcCollections`と`import Algorithms`の同時importは未検証。facadeはRedBlackTree・OptionalArray・BareArrayも再公開するので、その組み合わせでの名前解決も固定されていない |
| AtCoder 2025互換mode（`COMPATIBLE_ATCODER_2025`） | 互換modeの実装は未着手（`PERM-004`〜`PERM-010` FROZEN）。facadeは互換modeでだけ`RedBlackTreeModule`も再公開（`AcCollections.swift:6-8`） | なし。F0の非露出検査は互換modeで外れる（`_0_PublicSurfaceTests.swift:44`） | 互換modeのPermutationは、現行の通常版と同じsourceのまま（Permutation用の分岐はまだ無い） | 互換版（旧名`Permutations.*`、`unsafePermutations()`）とswift-algorithmsの同時import、互換版の`AcCollections`経由の利用は、実装後でなければ検証できない |

停止事項: なし。新しいdefectと判断点は見つからなかった。

Codex review（2026-10-08）: `PERM-026`を受け入れた。現行通常版については、直接依存する
swift-algorithmsとの同時import・主要入口の名前解決が仕様testで固定されているため、共存性を
`満たす`へ更新した。未実装で凍結中の互換modeと、将来のupstream変更は現行通常版の不足へ数えない。

### PERM-027 1.0前改善候補の実施前提 assignment（2026-10-08）

担当: Claude。R-2に列挙された性能CI、C++ `std::next_permutation`との差分比較、Linux CIのDeath Testの
3件について、現状、利用できる既存基盤、必須依存、実施時に変更する範囲、未確認事項を対応表にする。
既存Registry taskがある場合は対応付け、無い場合も新taskを自分で登録しない。

1.0前に必要か、どの順で行うか、品質評価を`満たす`へ上げる条件を決めない。性能基準、C++との
期待差分、CI構成も設計しない。source、test、benchmark、workflow、本文の評価語を変更せず、
新しい判断点またはdefectは根拠を記録して停止する。CodexがR-2をreviewする入力とする。

### PERM-027 1.0前改善候補3件の実施前提

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。HEAD `12d7f133`。読み取りだけで、benchmark・workflow・test・sourceは変更していない。
採否、順序、評価を上げる条件、性能基準、期待差分、CI構成は書いていない。

| 候補 | 現状 | 利用できる既存基盤 | 必須依存 | 実施時に変更する範囲 | 対応するRegistry task | 未確認事項 |
| --- | --- | --- | --- | --- | --- | --- |
| CIの性能比較にPermutationを加える（§3.2） | performance jobはPRのときだけ、base / HEADの両方でPR側のlibrary定義を走らせて比較する。5件目だけ`size <= 10` | `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift`の5計測。libraryを2本に分け、64kの4件と10の1件を同じ結果fileへ`replace-all`、`append`の順で記録できる | `Benchmarks`は別package。結果はPRのCIで出るのでユーザーのpushが要る | 実行構成の判断後、`CI.json`、小size用library、performance workflowを変更 | `PERM-013`（ACTIVE）。`PERM-031`で構成調査済み、`PERM-032`判断後に`PERM-033`で実装 | 初回CIの所要時間増分とsize列は実行時に確認 |
| C++ `std::next_permutation`との差分比較（§3.1） | Permutationの比較は無い（`CppBehaviorReference`にもそのtestにも`permutation`の語が無い） | `Sources/CppBehaviorReference`（C++。`extern "C"`の関数をheaderで公開、`Package.swift:274-277`）と`Tests/CppBehaviorReferenceTests`（赤黒木4型の比較、`SeededTraceSupport.swift`）。`CPP-001` DONE。実行実績はmacOS（libc++）のDebug・ReleaseとLinux（libstdc++）のDebug（`RED_BLACK_TREE_REMAINING_TASKS.md`の確認済み根拠） | `CppBehaviorReferenceTests`へ`PermutationModule`の依存を足す必要がある（現在の依存は`CppBehaviorReference`、`AcCollections`、`RedBlackTreeCollections`。`AcCollections`経由でも届く） | `Sources/CppBehaviorReference`へ`std::next_permutation`の`extern "C"` wrapperを追加し、`Tests/CppBehaviorReferenceTests`へ比較testを追加。依存を足すなら`Package.swift` | なし（`CPP-001`は「比較契約または対象環境を変更する場合だけ更新」、`CPP-002`はMSVCでEXCLUDED） | C++側は比較に`operator<`を使う。Swift側の`Comparable`と同じ結果になる入力の範囲（整数以外の要素型を比べるか）。libc++ / libstdc++の両方で同じ列挙になること |
| Linux CIでDeath Testを有効にする（§3.6） | CIはLinuxの`swift test -c debug` / `-c release`だけで、`ENABLE_DEATH_TESTS`を指定していない（`swift.yml:79-100`、workflow内に`DEATH`の語が無い） | trait `ENABLE_DEATH_TESTS`で`DEATH_TEST`を定義する設定（`Package.swift:85`）。Permutationの`_99_DeathTests`は正確なsignal（Linuxでは`SIGILL`）を期待する（`DeathTestSignal.swift`）。Linuxでの手動実行の手順は`Tests/CLAUDE.md`（`swift test -c debug --traits ENABLE_DEATH_TESTS,SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`） | traitを有効にするとPermutation以外のDeath Testも全部走る（OptionalArray、BareArray、RedBlackTree）。`Tests/CLAUDE.md`は、Linuxでは`SKIP_DEBUG_LIFETIME_BALANCE_CHECKS`との併用を指示している | `.github/workflows/swift.yml`へjobまたはstepを追加 | なし（Permutation専用のtaskも、全module共通のtaskも見つからない） | PermutationのDeath Testだけを走らせるか、全moduleで走らせるか（判断点の候補。Claudeは決めない）。Releaseでも走らせるか。Linuxで5件が`SIGILL`で止まることの最近の実行記録（RedBlackTree側の実績は文書にあるが、Permutationの記録は今回見つからない） |

停止事項: なし。新しいdefectは無い。上の表の「判断点の候補」（Linux Death Testの対象範囲）は、選択肢を書かずに位置だけを記録した。

Codex acceptance（2026-10-08）: 3候補の現状、既存基盤、依存、変更範囲、Registry対応、未確認事項が
採否と優先順位を決めずに分離されているため受け入れた。`PERM-027`を完了とし、R-2の判断は
`PERM-017`へ残す。

## 7. Codexレビュー結論（2026-10-08）

### R-1 品質特性の読み替え

妥当と判断する。インタラクション能力は、画面操作ではなくAPI利用者が目的、使い分け、入力条件、結果の
意味を理解して誤用を避けられるかとして読む。セキュリティは秘密情報ではなく、unsafe storage、範囲検査、
値の完全性を中心に読む。安全性は人命・財産・環境への危害を直接扱わないため対象外とし、メモリ安全性と
混同しない。この境界は§3.4、§3.6、§3.9で一貫している。

### R-2 1.0前改善候補

`部分`は不足を可視化する評価であり、全項目を`満たす`へ上げることを1.0の一律条件にはしない。

| 候補 | 結論 | 理由 |
| --- | --- | --- |
| 性能CIへのPermutation追加 | 1.0最終判断前の実施候補として維持 | 既存benchmarkはあるが継続比較へ入っておらず、inline属性削除と終端copy削減の影響が未計測。性能基準を決めずに評価語だけ上げない。実施は凍結中の`PERM-013`をユーザーが再開した場合に行う |
| C++ `std::next_permutation`との差分比較 | 1.0必須にしない | 公開契約はSwiftのTest as Specificationで固定され、C++ ABIや実装との互換を約束していない。追加すれば独立した比較契約と対象入力の判断が必要になる |
| Linux CIでDeath Testを有効化 | Permutation単独の1.0必須にしない | macOSのDebug／Releaseでは停止を確認済み。Linuxで有効にすると他moduleのDeath Testも同時に動くため、package全体のCI構成判断として分離すべきである |

したがって、現行通常版は評価に残る`部分`を既知事項として文書へ渡せる。性能比較を実施する場合も、
数値基準と評価語の変更は結果を見て別に判断する。

### R-3 利用者向け文書の選択肢

形式はここでは決めない。文書作業を開始するときの選択肢と技術的根拠は次のとおり。

| 選択肢 | 適する条件 | 注意点 |
| --- | --- | --- |
| Markdown本文 + documentation comment | 全順列との違い、列挙開始位置、重複要素、値semantics、計算量、短い使用例を一か所で説明し、RedBlackTree系文書と発見経路を揃える場合 | 本文とsymbol commentの責務を分け、仕様をtestと二重管理しない必要がある |
| DocC本文 + documentation comment | Xcodeのsymbol navigationと概念記事を同じ導線に置くことを優先する場合 | package全体の文書形式として採用するか、生成・公開方法を別途決める必要がある |
| documentation commentのみ | 公開入口が1つである小ささを優先し、使用例と使い分けをsymbol comment内で十分に説明できる場合 | 現状は使用例がなく、複数symbolをまたぐ概念説明と既知の品質上の制約が見つけにくい |

形式にかかわらず、利用者向け文書には少なくとも通常版だけを対象とすること、swift-algorithmsの全順列API
との使い分け、入力自身を含む後続順列の列挙、重複要素、結果の0始まりIndex、値semantics、1ステップ
最悪O(n)、`-Ounchecked`での範囲検査を含める。互換modeとの境界は、その実装を再開した場合に別途決める。

### R-4 事実と参照

`PERM-024`の照合を受け入れ、見つかった3点は`PERM-025`で補正済みである。共存性は`PERM-026`の
検証範囲を踏まえて現行通常版を`満たす`へ更新した。残る未確認は明示されており、初版の評価を覆す
参照誤りはない。

以上により、R-1〜R-4を閉じ、Permutation品質評価の初版レビューを完了する。この結論は通常版を
利用者向け文書作業へ渡せるという判定材料であり、互換modeの実装、利用者向け文書形式、性能基準、
1.0採用を決定するものではない。
