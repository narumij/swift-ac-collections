# OptionalArrayModule モジュール品質プロファイル

## 目的と適用範囲

この文書は、リポジトリ全体の上位品質要求をOptionalArrayModuleへ適用し、このモジュールで重視する品質、仕様の正本、検証証拠、および未確定領域の扱いを定める。

この文書だけで品質要求を新設または変更しない。上位品質要求の正本は`Maintanance/QUALITY_REQUIREMENTS.md`である。ISO/IEC 25010は品質観点を見落とさないための参照モデルとして用い、上位品質要求と並ぶ別の要求体系にはしない。

## 文書の位置づけ

この文書は、OptionalArrayModule固有の品質プロファイルであり、次を行う。

- 上位品質要求がこのモジュールで何を意味するかを説明する。
- optional要素、所有型、次元、メモリの品質境界を示す。
- 要求、公開契約、Test as Specification、およびその他の証拠を分離する。
- 未確定の並行利用と性能基準を、確認済みのstrict memory safety境界から分離する。

この文書は、Task Registry、公開API、Test as Specification、監査記録、benchmark、CI設定、および実行結果の代わりにはならない。それらと食い違う場合は、対象事項を担当する正本を確認し、この文書の記述を訂正する。

## 対象

主な対象は、`Sources/OptionalArrayModule/OptinalArray.swift`の所有1D〜4D型とその座標accessである。
旧連鎖subscriptと非所有View 1D〜3Dは削除済みであり、品質保証対象に含めない。

OptionalArrayは、要素ごとの有無を保持し、単一の連続storage上でoptional要素を扱う低レベル配列部品である。標準`Collection`への適合、一般的な配列API、任意の所有権管理を暗黙に要求へ含めない。

## 上位品質要求との接続

| 上位要求 | OptionalArrayModuleでの主な意味 | 主な仕様・証拠の接続先 |
| --- | --- | --- |
| QR-01 正確性 | 初期化、nil・non-nil状態、次元、offset、座標access、`removeAll()`、破棄が各契約どおり動作する | `OptionalArray_0`〜`_7`、`_97`、`_99`のTest as Specification |
| QR-02 性能効率性 | 連続storage、presence mapとpayload、O(1)要素access、allocation、および`removeAll()`の特性が目的に適する | sourceの計算量根拠、将来のbenchmark、CI performance evidence |
| QR-03 安全性 | raw pointer、初期化済み要素の寿命、`~Copyable`所有型、`@unchecked Sendable`、範囲・寸法検査の境界を維持する | 寿命test、Death Test、監査記録、Sanitizer、strict memory safety診断 |
| QR-04 理解可能性 | nil状態、座標と軸順、`removeAll()`、失敗条件を理解できる | documentation comment、利用者向け文書、Test as Specification |
| QR-05 利用可能性 | SwiftPM、`AcCollections`再公開、および競技用途の単一file・利用例経路で利用できる | facade test、package設定、単一file検証、EDPC利用例、CI、実利用記録 |
| QR-06 持続可能性 | 次元別の重複実装を変更しても、状態・寿命・安全性・性能を再確認できる | 番号付きTest as Specification、監査記録、CI、将来の性能証拠 |

この表は網羅的な個別テスト対応表ではない。各性質の詳細は、担当するTest as Specification、公開契約、監査記録、または測定記録で扱う。

## 仕様と証拠の境界

### Test as Specification

外部または内部から観察可能な契約について、実行可能な正本は`Tests/OptionalArrayModuleTests/`の番号付きテスト群とする。

| テスト群 | 主な担当領域 |
| --- | --- |
| `_0_PublicSurfaceTests` | 公開型、公開宣言、適合 |
| `_1_InitializationTests` | 初期化、寸法、zero dimension |
| `_2_ElementAccessTests` | nil・non-nilの読み書き、offset、座標access |
| 現行座標access仕様群 | 1D〜4Dの非対称shape全座標、選択位置だけの更新、値・nil遷移、参照要素寿命、全軸のread / write境界 |
| `_4_IndicesTests` | 各型の外側の軸を表す`indices` |
| `_5_RemoveAllTests` | `removeAll()`後の状態とcapacity再利用 |
| `_6_ReferenceLifetimeTests` | 参照型要素の構築・上書き・破棄 |
| `_97_CoordinateValueAccessDeathTests` | 座標accessの全軸に対する範囲違反 |
| `_99_DeathTests` | 寸法と次元積の事前条件違反 |

`EDPC-J.swift`と`EDPC-L.swift`は競技用途の利用形状を示すcompile evidenceであり、正答、実行時間、メモリ使用量、または実提出を証明しない。

品質要求と個別test functionの対応表は原則として別に維持しない。仕様を追加または変更するときは、その性質を担当するテスト群へ反映する。

### 公開文書と監査記録

documentation commentと利用者向け文書は、nil状態、所有権、軸、操作、制約、計算量、および失敗条件を利用者が理解するための入口である。`Maintanance/OptionalArrayModule/OptionalArrayAudit.md`は、公開面の棚卸し、過去の判断、および証拠の所在を記録する。監査記録の存在だけで現在の要求適合を証明したとはみなさない。

### 性能証拠

計算量の根拠、benchmarkによる測定、CI上の相対的な回帰判定、およびC/C++標準やSwiftの代替構造との外部比較は、それぞれ異なる問いに答える。

- 計算量は、実装と照合された公開契約または設計上の根拠が担当する。
- benchmarkが存在しない、または対象操作を含まない場合、実行時間や外部比較を推定しない。
- 将来の測定結果は、対象操作、入力形状、要素型、toolchain、最適化構成、および比較対象に限定された証拠とする。
- 有限回の測定や自己比較だけで、C/C++級の性能を証明したとはみなさない。

### CIと検証記録

CI設定は、実際に検証するtoolchain、platform、build configuration、trait、通常test、Death Test、Sanitizer、およびperformance jobの範囲を定める。jobの存在と、特定候補commitでの成功記録は区別する。

## 品質領域

### 1. 正確性と要素状態

少なくとも次の性質を、担当するTest as Specificationで扱う。

- nil・non-nil状態とpayloadの構築・破棄が対応すること。
- 1D〜4Dの寸法とoffsetが契約どおり対応すること。
- 非対称寸法、zero dimension、境界位置、および次元積overflowを契約どおり扱うこと。
- `setElement`が指定した座標だけを変更すること。
- `removeAll()`が全要素をnilへ戻し、再利用可能なcapacityを維持すること。
- `indices`が各型の外側の軸を表すこと。

### 2. 性能効率性

少なくとも次を区別して評価する。

- presence mapとpayloadの二領域allocationおよびメモリ局所性。
- `element`と`setElement`の計算量。
- 初期化、`removeAll()`、破棄、および次元積計算のコスト。
- 状態分岐と事前条件検査の最適化上の影響。
- Swiftの`Optional`配列、C/C++の候補表現、または他の構造との外部比較。

実装から読める計算量は、測定済みの実行性能ではない。性能基準と測定条件が確定するまで、性能要求への適合を主張しない。

### 3. 安全性

少なくとも次の領域を、通常テスト、寿命テスト、Death Test、compiler診断、および必要な動的検査で分担する。

- presence mapとpayload storageの確保、初期化、deinitialize、deallocateが対応すること。
- nilへの遷移、non-nil上書き、`removeAll()`、破棄で要素寿命を壊さないこと。
- 所有型の`~Copyable`境界。
- `@unchecked Sendable`が許す移送・共有の範囲。
- Debug、Release、`-Ounchecked`等によって事前条件の保証が変わる境界。
- strict memory safetyの現在設定と診断範囲。

並行利用、storage再設計、および`-Ounchecked`の位置づけには未確定または再審査待ちの領域がある。strict memory safetyはtargetへ恒久適用済みだが、その診断成功だけから個々のunsafe操作の正しさを推定しない。担当するTask Registryと監査記録で再開されるまで、この文書から新しい公開保証を導かない。

### 4. 理解可能性

利用者が少なくとも次を確認できるようにする。

- nil・non-nilの意味と、座標accessを使う現行経路。
- 各次元の意味、initializerと`element`／`setElement`の座標順。
- `removeAll()`、capacity保持、zero dimension、範囲外、および次元積overflow。
- 標準`Collection`ではないことと、提供する操作の範囲。
- `@unchecked Sendable`と`-Ounchecked`の保証境界。

### 5. 利用可能性

一般Swift開発については、SwiftPMによる導入、`AcCollections`からの再公開、対象toolchain・platform、および他moduleとの共存を扱う。

競技用途については、単一fileとしてのbuild、EDPC利用例のcompile、実際の提出、正答、実行時間、およびメモリ使用量を区別する。compileやsample成功だけから、実提出または利用目的上のValidation成功を推定しない。

### 6. 持続可能性

公開表面、nil状態、次元、offset、`removeAll()`、寿命、停止契約、および性能を、変更範囲に応じて再確認できる構造を維持する。

調査記録は証拠として保存するが、時点の異なる評価やtask進行を現行プロファイルへ追記し続けない。現在評価と長い調査履歴を分離し、過去の結論を現行の事実として自動的に流用しない。

## 変更時の確認

変更範囲に応じて、少なくとも次を確認する。

1. 関連するTest as Specificationが成功する。
2. storage、initializer、座標access、`removeAll()`、または破棄を変更した場合、状態、寸法、offset、寿命、および停止契約を確認する。
3. hot path、allocation、状態分岐、次元積、または検査を変更した場合、計算量と性能証拠への影響を確認する。
4. 公開API、文書、再公開、toolchain、platform、またはbuild条件を変更した場合、利用者が到達する各経路を確認する。
5. Sendable、strict memory safety等の凍結領域へ影響する場合、既存taskを勝手に再開せず停止する。

具体的なrelease gateは、対象releaseの計画とCI設定で定める。この文書へ特定releaseやtaskの進行状態を記録しない。

## 現在評価の扱い

この文書の作成時点では、旧品質評価を現行実装と一項目ずつ再照合した完全な現在評価は行っていない。そのため、旧文書の`満たす`、`部分`、`未評価`、`対象外`などの判定を、現行版へそのまま引き継がない。

現在評価を行う場合は、上位品質要求の語彙に従い、各品質主張について次を区別する。

- 確認済み
- 未達
- 未検証
- 対象外
- 受容済みの残余リスク

各判定には、要求、公開契約または設計契約、証拠、実行構成、結果、反証、および残余リスクを対応づける。Verificationの成功だけから、競技利用、C/C++級性能、または一般Swift開発での採用というValidationの成功を推定しない。

## 関連する正本

| 対象 | 正本 |
| --- | --- |
| リポジトリ全体の上位品質要求 | `Maintanance/QUALITY_REQUIREMENTS.md` |
| 現在のtask状態、所有者、依存、再開条件 | `Maintanance/PROGRESS_OVERVIEW.md`のTask Registry |
| 観察可能な仕様 | `Tests/OptionalArrayModuleTests/`の番号付きTest as Specification |
| 公開APIとdocumentation comment | `Sources/OptionalArrayModule/OptinalArray.swift` |
| 公開面の棚卸し、判断、証拠の所在 | `Maintanance/OptionalArrayModule/OptionalArrayAudit.md` |
| 競技用途のcompile evidence | `Tests/OptionalArrayModuleTests/EDPC-J.swift` / `EDPC-L.swift` |
| 性能測定対象と継続測定構成 | `Benchmarks/`およびGitHub Actions（対象が存在する場合） |
| 特定commit・環境での調査結果 | 対象調査またはreleaseの記録 |

## 関連文書

- [上位品質要求](../../../Maintanance/QUALITY_REQUIREMENTS.md)
- [旧品質評価・調査記録（2026-10-08時点）](../../../Maintanance/Archived/Quality/OptionalArray_QualityAssessment-ISO25010_2026-10-08.md)
