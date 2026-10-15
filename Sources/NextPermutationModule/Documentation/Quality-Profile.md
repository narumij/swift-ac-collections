# NextPermutationModule モジュール品質プロファイル

## 目的と適用範囲

この文書は、リポジトリ全体の上位品質要求をNextPermutationModuleへ適用し、このモジュールで重視する品質、仕様の正本、検証証拠、および未確定領域の扱いを定める。

この文書だけで品質要求を新設または変更しない。上位品質要求の正本は`Maintanance/Current/QUALITY_REQUIREMENTS.md`である。ISO/IEC 25010は品質観点を見落とさないための参照モデルとして用い、上位品質要求と並ぶ別の要求体系にはしない。

## 文書の位置づけ

この文書は、NextPermutationModule固有の品質プロファイルであり、次を行う。

- 上位品質要求がこのモジュールで何を意味するかを説明する。
- 要求、公開契約、Test as Specification、およびその他の証拠を分離する。
- 通常版とAtCoder 2025互換modeの評価境界を明確にする。
- 未検証事項と利用目的上のValidationを、実装のVerificationから分離する。

この文書は、Task Registry、公開API、Test as Specification、benchmark、CI設定、および実行結果の代わりにはならない。それらと食い違う場合は、対象事項を担当する正本を確認し、この文書の記述を訂正する。

## 対象

通常版の主な対象は、`Collection.nextPermutations()`と、要素bufferを所有して各順列を一時的な
`Permutation` Viewとして貸し出す`NextPermutations`である。`NextPermutations`は`~Copyable`であり、
`Sequence`には適合しない。返されたViewは次のmutating accessまたは所有者の破棄で失効し、以後のaccessを
runtime checkで拒否する。

旧`NextPermutationsSequence`、その`Iterator`と`Permutation`、Copy on Write、および結果値の
永続的な値セマンティクスは、現行通常版の契約として扱わない。旧testは契約移行の履歴資料であり、
現行仕様または成功証拠ではない。無効化されていた旧Swift 6.2実装は、現行runtime-check View版が
Swift 6.2で成立したため削除した。

AtCoder 2025互換modeは同じ製品目的へ関係するが、公開表面、実装、build条件、および検証経路が通常版と異なる。通常版の証拠を互換modeへ、互換modeの証拠を通常版へ自動的に適用しない。

## 公開名称と改名時の品質境界

採用名は`NextPermutationModule`と、通常版一時Viewの`NextPermutations.Permutation`である。
名称・理由・互換方針の正本は`Maintanance/Current/PUBLIC_API_NAMING_DECISIONS.md`とする。
実装と主入口は`NextPermutationModule`にあり、旧`PermutationModule`は同じ宣言を再公開する互換入口である。

改名時はQR-04・QR-05・QR-06に対応して、moduleの導入・import、`AcCollections`からの再公開、
公開型の名前解決、DocCの入口・symbol link、使用例、および関連する検証経路の整合を確認する。
旧module名の互換targetは維持する。具体構成と検証工程は`Maintanance/Current/PERMUTATION_MODULE_MIGRATION_PLAN.md`、今回の受入範囲は`Maintanance/Archived/PermutationMigration_2026-10-16/PERMUTATION_MODULE_MIGRATION_ACCEPTANCE.md`を参照する。

通常版一時Viewはnested名`Permutation`を維持する。名前だけで寿命契約を伝えたとは扱わず、
型の冒頭説明・使用例・失効時の診断で、一時Viewであること、次の`next()`やowner破棄で失効すること、
保存には`Array`等へのcopyが必要なことを維持する。列挙・所有・失効の契約は改名によって変えない。
三者の名称合意は、利用者が契約を理解できるというValidationの証拠には代えない。

## 上位品質要求との接続

| 上位要求 | NextPermutationModuleでの主な意味 | 主な仕様・証拠の接続先 |
| --- | --- | --- |
| QR-01 正確性 | 入力自身を含む後続順列を契約どおり列挙し、境界、重複要素、終了、および有効なViewの要素順が正しい | runtime-check契約に対応するTest as Specification、件数・checksum検査 |
| QR-02 性能効率性 | 入力bufferの準備、in-placeの1 step、runtime-check付きViewのアクセス、allocation、および列挙全体の特性が目的に適する | sourceの計算量契約、`PermutationBenchmarks.swift`、benchmark library、CI performance job、外部比較記録 |
| QR-03 安全性 | bufferの単独所有、要素寿命、View失効後のaccess拒否、破棄、scoped `unsafe`、および最適化構成ごとの保証境界を維持する | runtime Death Test、strict memory safety診断、所有・破棄test、Sanitizer等 |
| QR-04 理解可能性 | 後続順列と全順列の違い、手動反復、重複要素、Viewの有効期間と失効、計算量を利用者が理解できる | 公開APIのdocumentation comment、利用者向け文書、Test as Specification |
| QR-05 利用可能性 | Swift 6.4以降の一般Swift開発で導入・共存でき、対応toolchain別の提供範囲を識別できる | SwiftPM manifest、公開surface test、`AcCollections`再公開test、共存test、一般利用Validation scenario |
| QR-06 持続可能性 | 公開表面、列挙、View失効・所有権、安全性、toolchain別提供範囲、および性能を変更後に再確認できる | 現行契約のTest as Specification、必要なcompiler fixture、benchmark、CI、設計・調査記録 |

この表は網羅的な個別テスト対応表ではない。各性質の詳細は、担当するTest as Specification、公開契約、または測定記録で扱う。

## 仕様と証拠の境界

### Test as Specification

通常版の外部または内部から観察可能な契約について、実行可能な正本は、runtime-check付き
`NextPermutations`へ対応するTest as Specificationとする。

現行通常版のTest as Specificationは`Tests/PermutationTests/NextPermutations/`にあり、次の担当領域を
分離する。runtimeでは表現できない非copy、非`Sequence`、直接初期化不可などの表面契約は、
`Utilities/Maintenance/CompilerDiagnostics/PermutationPublicSurface/`のcompiler fixtureが担当する。

| 担当領域 | 主な検証対象 |
| --- | --- |
| 公開表面 | `nextPermutations()`、`NextPermutations`、公開・非公開の宣言、`~Copyable`境界 |
| 列挙 | 列挙順、空・単要素・最終順、重複要素、入力Collection、終了後の反復 |
| View有効期間 | 現在のViewを読み取れることと、次のmutating accessまたはowner破棄後のaccessがruntimeで拒否されること |
| 所有と破棄 | 入力からの初期copy、要素の初期化・破棄対応、iterator破棄時の全要素解放 |
| 共存 | `AcCollections`再公開、他moduleとの名前解決、toolchain別manifestの公開範囲 |
| 境界 | Viewの有効期間、0始まりのIndex、subscriptの範囲検査、および停止条件 |

`Tests/PermutationTests/NextPermutationsSequence/`の番号付きテスト群は旧COW契約を対象としており、
`#if false`で退避された履歴資料である。現行通常版のTest as Specificationまたは成功証拠には用いない。

View失効と範囲外accessの拒否は、通常runtime testとprocessを分離するDeath Testで検証経路を分ける。
`~Copyable`や公開表面の否定的要件などruntimeで表現できない性質には、必要に応じてcompiler fixtureを用いる。

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

### 1. 正確性と手動反復

少なくとも次の性質を、担当するTest as Specificationで扱う。

- 入力自身から始まり、辞書順で後続する順列を列挙すること。
- 空、単一要素、最終順列、重複要素、および非Int Indexの入力を契約どおり扱うこと。
- 入力Collectionの要素をiterator所有bufferへ一度copyし、入力自身を変更しないこと。
- 各`next()`が現在の要素順を0始まりの`Permutation` Viewとして返すこと。
- 返されたViewが有効な間はその要素順を読み取れ、次のmutating accessまたはowner破棄後のaccessは
  runtime checkで拒否されること。
- `NextPermutations`をcopyできず、終了後の`next()`が一貫して`nil`を返すこと。

Swift標準protocolの契約へ違反する入力型に対する防御を要求する場合は、通常の適合型に対する契約と分けて明示する。

### 2. 性能効率性

少なくとも次を区別して評価する。

- 一つの後続順列を生成する計算量。
- 入力から内部bufferを準備するコスト。
- 反復中に順列ごとのallocationまたは全要素copyを行わないこと。
- runtime-check付き`Permutation` Viewの走査とsubscriptの特性。
- 全列挙に固有の階乗的な出力数。

有限回のbenchmarkだけで計算量やC/C++級の性能を証明したとはみなさない。回帰判定ではbaseとHEADの条件を揃え、外部比較では対象実装、入力、toolchain、最適化構成、測定方法を明示する。

### 3. 安全性

少なくとも次の領域を、通常テスト、内部テスト、Death Test、必要なcompiler診断、および動的検査で分担する。

- iteratorがbufferを単独所有し、全初期化済み要素を一度だけ破棄すること。
- Viewがownerより長く生存した場合や次のmutating access後に、要素pointerへ触れる前に失効を検出すること。
- `~Copyable`によってiterator所有権を暗黙に複製できないこと。
- 有効なViewでも範囲外位置を公開契約に従って拒否すること。
- Debug、Release、`-Ounchecked`、traitなどによって保証が変わる場合、その境界を明示すること。
- 通常版targetへのstrict memory safety適用と、scoped `unsafe`が覆う範囲を確認できること。適用済みであることだけから、個々の危険操作の妥当性まで推定しない。

toolchain固有の最適化事象や未再現の性能事象は、原因と適用範囲が確認されるまで製品契約へ取り込まない。

### 4. 理解可能性

利用者が少なくとも次を確認できるようにする。

- 全順列ではなく、入力自身を含む後続順列を列挙するAPIであること。
- 重複要素を含む場合の列挙結果。
- `Sequence`や永続的な結果値ではなく、`next()`で一時Viewを逐次処理するAPIであること。
- iteratorをcopyできず、保持したViewは次のmutating accessやiterator寿命の外では失効すること。
- 結果の0始まり位置、計算量、終了、および失敗条件。
- swift-algorithms等の類似APIとの用途上の違い。
- 通常版とAtCoder 2025互換modeの境界。

### 5. 利用可能性

一般Swift開発については、Swift 6.4以降を通常版の基準とし、SwiftPMによる導入、
`AcCollections`からの再公開、他moduleとの共存、対象toolchainとplatformを扱う。

現行package manifestのtools versionはSwift 6.4である。runtime-check実装自体がSwift 6.2で成立するという
調査結果はあるが、package全体の6.2提供条件とversion-specific manifestの必要性は未確定であり、
現行の提供範囲または縮小提供方針として扱わない。

競技用途については、互換modeのbuild、公開表面、単一file生成、および実際の提出環境での利用を区別する。単一fileの生成やsample成功だけから、実提出によるValidationの成功を推定しない。

### 6. 持続可能性

公開表面、列挙、View失効・所有権、要素寿命、共存性、toolchain別提供範囲、停止契約、および性能を、
変更範囲に応じて再確認できる構造を維持する。

調査記録は証拠として保存するが、時点の異なる評価やtask進行を現行プロファイルへ追記し続けない。現在評価と長い調査履歴を分離し、過去の結論を現行の事実として自動的に流用しない。

## 変更時の確認

変更範囲に応じて、少なくとも次を確認する。

1. 関連する通常版または互換modeのTest as Specificationが成功する。
2. iterator、buffer、View失効、subscript、または終了処理を変更した場合、所有権、有効期間、範囲検査、および破棄を確認する。
3. hot path、in-place更新、allocation、または計算量に影響する変更では、benchmark構成と測定結果への影響を確認する。
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
| リポジトリ全体の上位品質要求 | `Maintanance/Current/QUALITY_REQUIREMENTS.md` |
| 現在のtask状態、所有者、依存、再開条件 | `Maintanance/ProgressV2/TASK_REGISTRY_V2.md` |
| 通常版の観察可能な仕様 | `Tests/PermutationTests/NextPermutations/`のruntime Test as Specificationと`Utilities/Maintenance/CompilerDiagnostics/PermutationPublicSurface/`のcompiler fixture。分類、受入境界、実行証拠は`Maintanance/PermutationModule/RuntimeCheckedPermutationTestPlan.md`を参照し、退避中の旧testを現行仕様と扱わない |
| AtCoder 2025互換modeの観察可能な仕様 | `Tests/PermutationTests/AtCoder2025Compatibility/` |
| 公開APIとdocumentation comment | `Sources/NextPermutationModule/NextPermutations.swift`および互換modeのsource |
| 性能測定対象 | `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift` |
| 継続測定の対象と構成 | `Benchmarks/Libraries/*.json`およびGitHub Actions |
| 特定commit・環境での調査結果 | 対象調査またはreleaseの記録 |

## 関連文書

- [上位品質要求](../../../Maintanance/Current/QUALITY_REQUIREMENTS.md)
- [旧品質評価・調査記録（2026-10-09時点）](../../../Maintanance/Archived/Quality/Permutation_QualityAssessment-ISO25010_2026-10-09.md)
