# PermutationModule モジュール品質プロファイル

## 目的と適用範囲

この文書は、リポジトリ全体の上位品質要求をPermutationModuleへ適用し、このモジュールで重視する品質、仕様の正本、検証証拠、および未確定領域の扱いを定める。

この文書だけで品質要求を新設または変更しない。上位品質要求の正本は`Maintanance/User/QUALITY_REQUIREMENTS.md`である。ISO/IEC 25010は品質観点を見落とさないための参照モデルとして用い、上位品質要求と並ぶ別の要求体系にはしない。

## 文書の位置づけ

この文書は、PermutationModule固有の品質プロファイルであり、次を行う。

- 上位品質要求がこのモジュールで何を意味するかを説明する。
- 要求、公開契約、Test as Specification、およびその他の証拠を分離する。
- 通常版とAtCoder 2025互換modeの評価境界を明確にする。
- 未検証事項と利用目的上のValidationを、実装のVerificationから分離する。

この文書は、Task Registry、公開API、Test as Specification、benchmark、CI設定、および実行結果の代わりにはならない。それらと食い違う場合は、対象事項を担当する正本を確認し、この文書の記述を訂正する。

## 対象

通常版の主な対象は、`Collection.nextPermutations()`、`NextPermutationsSequence`、その`Iterator`と`Permutation`である。

AtCoder 2025互換modeは同じ製品目的へ関係するが、公開表面、実装、build条件、および検証経路が通常版と異なる。通常版の証拠を互換modeへ、互換modeの証拠を通常版へ自動的に適用しない。

## 上位品質要求との接続

| 上位要求 | PermutationModuleでの主な意味 | 主な仕様・証拠の接続先 |
| --- | --- | --- |
| QR-01 正確性 | 入力自身を含む後続順列を契約どおり列挙し、境界、重複要素、終了、値セマンティクス、結果Collectionの振る舞いが正しい | `NextPermutationsSequence_0`〜`_3`、`_98`、`_99`のTest as Specification |
| QR-02 性能効率性 | 1ステップの計算量、入力buffer、Copy on Write、結果アクセス、allocation、および列挙全体の特性が目的に適する | sourceの計算量契約、内部検査、`PermutationBenchmarks.swift`、benchmark library、CI performance job |
| QR-03 安全性 | iterator copyと結果値の独立性、bufferの所有権と寿命、範囲検査、破棄、および最適化構成ごとの保証境界を維持する | `_2_ValueSemanticsTests`、`_98_InternalTests`、`_99_DeathTests`、strict memory safety診断、Sanitizer等 |
| QR-04 理解可能性 | 後続順列と全順列の違い、列挙開始位置、重複要素、結果Index、失敗条件、計算量を利用者が理解できる | 公開APIのdocumentation comment、利用者向け文書、Test as Specification |
| QR-05 利用可能性 | SwiftPMと一般Swift開発で導入・共存でき、競技用途では互換modeと単一file経路を利用できる | `_0_PublicSurfaceTests`、`_4_CoexistenceTests`、`AcCollections`再公開test、互換modeのspecification test、実提出記録（ユーザー専任・未実施） |
| QR-06 持続可能性 | 公開表面、列挙、値セマンティクス、Collection適合、共存性、安全性、性能を変更後に再確認できる | 番号付きTest as Specification、benchmark、CI、設計・調査記録 |

この表は網羅的な個別テスト対応表ではない。各性質の詳細は、担当するTest as Specification、公開契約、または測定記録で扱う。

## 仕様と証拠の境界

### Test as Specification

通常版の外部または内部から観察可能な契約について、実行可能な正本は`Tests/PermutationTests/NextPermutationsSequence/`の番号付きテスト群とする。

| テスト群 | 主な担当領域 |
| --- | --- |
| `_0_PublicSurfaceTests` | 公開入口、公開・非公開の表面 |
| `_1_EnumerationTests` | 列挙順、境界、重複要素、入力Collection |
| `_2_ValueSemanticsTests` | iteratorと結果の値セマンティクス |
| `_3_PermutationCollectionTests` | 結果Collection、Index、等値性、hash、表示 |
| `_4_CoexistenceTests` | 他moduleとの共存と名前解決 |
| `_98_InternalTests` | 公開契約ではない内部のCopy on Write・破棄等の検査 |
| `_99_DeathTests` | 事前条件違反時の停止契約 |

AtCoder 2025互換modeの観察可能な契約は、`Tests/PermutationTests/AtCoder2025Compatibility/`のTest as Specificationが担当する。

品質要求と個別test functionの対応表は原則として別に維持しない。仕様を追加または変更するときは、その性質を担当するテスト群へ反映する。

### 公開文書

documentation commentと利用者向け文書は、利用者が契約、用途、制約、計算量、および失敗条件を理解するための入口である。テストだけに存在する内部最適化や原因未確定の事象を、公開保証として記載しない。

### 性能証拠

計算量の契約、benchmarkによる測定、CI上の相対的な回帰判定、およびC/C++標準との外部比較は、それぞれ異なる問いに答える。

- 計算量は、実装と照合された公開契約または設計上の根拠が担当する。
- `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift`は測定対象と手順を提供する。
- `Benchmarks/Libraries/CI.json`、`CI-Small.json`およびworkflowは、継続比較へ含める構成を定める。
- 特定commit間の測定結果は、その環境と条件に限定された証拠である。
- C++の`std::next_permutation`との意味または性能の比較は、独立した比較条件と証拠がない限り推定しない。

### CIと検証記録

CI設定は、実際に検証するtoolchain、platform、build configuration、trait、通常test、Death Test、およびperformance jobの範囲を定める。strict memory safetyは`Package.swift`のtarget設定によるbuild時診断であり、専用のCI jobが存在することを意味しない。jobや設定の存在と、特定候補commitでの成功記録は区別する。

## 品質領域

### 1. 正確性と値セマンティクス

少なくとも次の性質を、担当するTest as Specificationで扱う。

- 入力自身から始まり、辞書順で後続する順列を列挙すること。
- 空、単一要素、最終順列、重複要素、および非Int Indexの入力を契約どおり扱うこと。
- iteratorのコピーと、列挙結果として保持した値が契約どおり独立すること。
- `Permutation`が0始まりのIndexを持つCollectionとして振る舞うこと。
- 終了後のiterator、範囲外subscript、および直接初期化などの境界を契約どおり扱うこと。

Swift標準protocolの契約へ違反する入力型に対する防御を要求する場合は、通常の適合型に対する契約と分けて明示する。

### 2. 性能効率性

少なくとも次を区別して評価する。

- 一つの後続順列を生成する計算量。
- 入力から内部bufferを準備するコスト。
- iteratorまたは結果をコピーした場合のCopy on Write。
- `Permutation`の走査とsubscriptの特性。
- 全列挙に固有の階乗的な出力数。

有限回のbenchmarkだけで計算量やC/C++級の性能を証明したとはみなさない。回帰判定ではbaseとHEADの条件を揃え、外部比較では対象実装、入力、toolchain、最適化構成、測定方法を明示する。

### 3. 安全性

少なくとも次の領域を、通常テスト、内部テスト、Death Test、compiler診断、および必要な動的検査で分担する。

- bufferとheaderの構築・破棄が対応すること。
- iterator copyと結果保持によって共有値を意図せず変更しないこと。
- 範囲外Indexを公開契約どおり拒否すること。
- Debug、Release、`-Ounchecked`、traitなどによって保証が変わる場合、その境界を明示すること。
- 通常版targetへのstrict memory safety適用と、scoped `unsafe`が覆う範囲を確認できること。適用済みであることだけから、個々の危険操作の妥当性まで推定しない。

toolchain固有の最適化事象や未再現の性能事象は、原因と適用範囲が確認されるまで製品契約へ取り込まない。

### 4. 理解可能性

利用者が少なくとも次を確認できるようにする。

- 全順列ではなく、入力自身を含む後続順列を列挙するAPIであること。
- 重複要素を含む場合の列挙結果。
- iteratorと結果値の保持・コピーの意味。
- 結果のIndex体系、計算量、終了、および失敗条件。
- swift-algorithms等の類似APIとの用途上の違い。
- 通常版とAtCoder 2025互換modeの境界。

### 5. 利用可能性

一般Swift開発については、SwiftPMによる導入、`AcCollections`からの再公開、他moduleとの共存、対象toolchainとplatformを扱う。

競技用途については、互換modeのbuild、公開表面、単一file生成、および実際の提出環境での利用を区別する。単一fileの生成やsample成功だけから、実提出によるValidationの成功を推定しない。

### 6. 持続可能性

公開表面、列挙、値セマンティクス、Collection適合、共存性、停止契約、および性能を、変更範囲に応じて再確認できる構造を維持する。

調査記録は証拠として保存するが、時点の異なる評価やtask進行を現行プロファイルへ追記し続けない。現在評価と長い調査履歴を分離し、過去の結論を現行の事実として自動的に流用しない。

## 変更時の確認

変更範囲に応じて、少なくとも次を確認する。

1. 関連する通常版または互換modeのTest as Specificationが成功する。
2. iterator、buffer、Permutation、subscript、または終了処理を変更した場合、値セマンティクス、寿命、範囲検査、および破棄を確認する。
3. hot path、Copy on Write、allocation、または計算量に影響する変更では、benchmark構成と測定結果への影響を確認する。
4. 公開API、文書、再公開、依存、trait、またはbuild条件を変更した場合、利用者が到達する各経路を確認する。
5. 競技用途の互換経路を変更した場合、一般用途の通常版へ影響がないことを別に確認する。

具体的なrelease gateは、対象releaseの計画とCI設定で定める。この文書へ特定releaseやtaskの進行状態を記録しない。

## 現在評価の扱い

この文書の作成時点では、旧品質評価を現行実装と一項目ずつ再照合した完全な現在評価は行っていない。そのため、旧文書の`満たす`、`部分`、`対象外`などの判定を、現行版へそのまま引き継がない。

現在評価を行う場合は、上位品質要求の語彙に従い、各品質主張について次を区別する。

- 確認済み
- 未達
- 未検証
- 対象外
- 受容済みの残余リスク

各判定には、要求、公開契約または設計契約、証拠、実行構成、結果、反証、および残余リスクを対応づける。Verificationの成功だけから、競技提出、C/C++級性能、または一般Swift開発での採用というValidationの成功を推定しない。

## 関連する正本

| 対象 | 正本 |
| --- | --- |
| リポジトリ全体の上位品質要求 | `Maintanance/User/QUALITY_REQUIREMENTS.md` |
| 現在のtask状態、所有者、依存、再開条件 | `Maintanance/PROGRESS_OVERVIEW.md`のTask Registry |
| 通常版の観察可能な仕様 | `Tests/PermutationTests/NextPermutationsSequence/` |
| AtCoder 2025互換modeの観察可能な仕様 | `Tests/PermutationTests/AtCoder2025Compatibility/` |
| 公開APIとdocumentation comment | `Sources/PermutationModule/Permutations.swift`および互換modeのsource |
| 性能測定対象 | `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift` |
| 継続測定の対象と構成 | `Benchmarks/Libraries/*.json`およびGitHub Actions |
| 特定commit・環境での調査結果 | 対象調査またはreleaseの記録 |

## 関連文書

- [上位品質要求](../../../Maintanance/User/QUALITY_REQUIREMENTS.md)
- [旧品質評価・調査記録（2026-10-09時点）](../../../Maintanance/Archived/Quality/Permutation_QualityAssessment-ISO25010_2026-10-09.md)
