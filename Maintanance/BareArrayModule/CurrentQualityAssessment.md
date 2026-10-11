# BareArrayModule Current Quality Assessment

## 文書の役割

この文書は、BareArrayModuleの現行品質評価taskの詳細正本である。
上位品質要求は`Maintanance/User/QUALITY_REQUIREMENTS.md`、モジュールへの適用と証拠境界は
`Sources/BareArrayModule/Documentation/Quality-Profile.md`を正本とする。
本書はそれらを変更せず、Quality Profileの現在性確認、現在評価の作業範囲、完了条件、結果を管理する。

## Task

- ID: `BARE-016`
- 種別: `DISCOVERY`
- 担当: Codex
- 現在の中間ゴールへの近さ: `DIRECT`

現在の状態、担当、および再開条件はTask Registryを正本とする。

### 実行内訳

| 内訳 | 内容 | 状態 |
| --- | --- | --- |
| A | Quality Profileの現在性監査と必要なリフレッシュ | 完了（リフレッシュ不要） |
| B | 公開契約・実装・Test as Specificationの照合 | 完了 |
| C | 現行test・build・安全性証拠の取得 | 完了 |
| D | 性能証拠・CI構成・利用経路の照合 | 完了 |
| E | QR-01〜QR-06の評価と後続task候補の分離 | 完了 |

## 目的

BareArrayModuleについて、上位品質要求QR-01〜QR-06に対する現行実装の品質を、現在の仕様と
独立した証拠に基づいて評価可能な状態にする。

評価開始時にQuality Profile自体の現在性を確認し、上位要求、公開契約、対象、証拠境界に問題が
あれば、評価を始める前にProfileをリフレッシュする。Profileを固定された前提とは扱わず、評価で
反証された場合もProfile確認へ戻る。

旧評価の判定を引き継がず、各品質主張を次のいずれかへ分類する。

- 確認済み
- 未達
- 未検証
- 対象外
- 受容済みの残余リスク

## 対象

- 所有1D〜4D型と非所有View 1D〜3Dの公開API、実装、Test as Specification、documentation comment
- storage、初期化、次元、offset、subscript、writeback、要素寿命、View寿命、Sendableの境界
- benchmark対象、継続測定構成、および現在利用できる性能証拠
- SwiftPM、`AcCollections`再公開、競技用途の単一file経路
- CIが実際に扱うtoolchain、platform、build configuration、trait、test
- strict memory safety、Sanitizer、Death Test、`-Ounchecked`に関する現在の証拠境界

## 対象外

- 公開契約、性能目標、比較水準、残余リスク許容条件の新規決定
- 未確定事項をagent判断で製品契約へ取り込むこと
- 発見した不足の実装修正
- BareArray以外のモジュールの品質評価
- 凍結中の性能測定、View寿命・storage再設計・strict memory safety課題の暗黙の再開

## Quality Profile現在性監査

評価開始時点は2026-10-11、branch `develop/misc/55`。

### 結果

現行Quality Profileのリフレッシュは不要と判定した。

- QR-01〜QR-06への接続は、現行の上位品質要求と一致する。
- 対象として記載された所有4型、非所有View 3型、および`BareArray.swift`は現行sourceと一致する。
- 番号付きTest as Specification 8群は現行test配置と一致する。
- 性能測定、View寿命、並行利用、strict memory safety、`-Ounchecked`を未確定領域として分離しており、
  現在のRegistryと監査記録を先取りしていない。
- Profile整備commit `74deff9e`以後、BareArrayのsourceとTest as Specificationに意味的変更はない。
  評価開始後のフィードバックにより、BareArrayModule targetへ`.strictMemorySafety()`を追加して観測している。この変更は
  Profileが既に定めるstrict memory safetyの証拠境界を変えず、現在評価の結果だけを更新する。
- Profileは現在評価を内包せず、評価区分と必要な証拠項目だけを規定しているため、今回の結果をProfileへ
  追記する必要はない。

この判定はProfileの永久固定を意味しない。後続照合で対象、契約、証拠境界への反証が出た場合は、
評価を止めて本節へ戻る。

## 作業

1. Quality Profileの対象、品質主張、証拠境界を上位要求、source、test、Registryと照合する。
2. QR-01〜QR-06ごとに評価対象となる品質主張を抽出する。
3. 各主張を担当する公開契約、設計契約、Test as Specification、測定、CI構成へ接続する。
4. 証拠の現在性、対象構成、実行結果、反証、証明できる範囲を確認する。
5. 各主張を評価区分へ分類し、VerificationとValidationを分離する。
6. 不足を`DISCOVERY`、一判断ごとの`DECISION`、方針確定後の`EXECUTION`、既存taskへ分ける。
7. 後続候補の現在の中間ゴールへの必要性と近さを示し、必要なものだけRegistry候補として提示する。

## 成果物

現在評価は本書へ記録する。長い調査ログや再実行用データが必要になった場合は、本書から参照する
別紙へ分離し、同じ判定を重複して正本化しない。

最低限、品質主張、対応する上位要求、仕様の正本、証拠と対象構成、評価区分、根拠、反証または
未確認範囲、残余リスク、必要な後続task候補を残す。

## 完了条件

- Quality Profileの現在性を確認し、必要な場合は評価前にリフレッシュしている。
- QR-01〜QR-06の各領域について、少なくとも一つの現行評価が記録されている。
- Verificationから競技利用、C/C++級性能、一般Swift開発での採用というValidationを推定していない。
- View寿命、Sendable、strict memory safety、`-Ounchecked`の未確定事項をagent判断で閉じていない。
- 未達・未検証・判断待ち・実行不足が区別され、一判断一taskの規則で後続候補へ分離されている。
- ユーザーが評価結果と後続候補をレビューできる。

## 現行評価

評価日は2026-10-11。旧品質評価の判定は継承せず、現在性を確認したsource、Test as Specification、
Package設定、benchmark、workflow、および今回の実行結果から評価する。

| 上位要求 | 品質主張 | 評価 | 現在の証拠 | 未確認範囲・残余リスク |
| --- | --- | --- | --- | --- |
| QR-01 正確性 | 初期化、次元、offset、subscript、View、writeback、破棄が公開契約どおり動作する | 確認済み | Debug 35件、Release 28件、両構成のDeath Test 39件が現行環境で成功。実行不能となった3件はcompiler診断fixtureへ移行 | 有限な入力と構成による確認であり、任意の次元・要素型の数学的証明ではない |
| QR-02 性能効率性 | 実装上の計算量と連続storageの設計根拠が公開契約と一致する | 確認済み | 所有4型は要素数分を一括allocateし、subscriptとView生成は定数回のoffset計算、初期化と破棄は要素数に比例する。公開documentation commentの計算量と一致 | 実装構造から確認した計算量であり、実行時間、allocation cost、最適化結果を証明しない |
| QR-02 性能効率性 | C/C++標準に匹敵する性能を持つ | 未検証 | BareArray固有のbenchmarkと外部比較結果は未確認 | 比較対象、利用scenario、測定条件、判定水準が未確定 |
| QR-03 安全性 | 所有storage、要素寿命、範囲拒否、writeback拒否が契約どおり動く | 確認済み | 参照寿命test、通常test、Death TestがDebug・Releaseで成功し、Address Sanitizer構成でも通常35件・Death Test 42件が成功 | testが通る有限経路の証拠であり、非所有Viewの寿命全体は含まない |
| QR-03 安全性 | View寿命、Sendableとの交差、strict memory safety、`-Ounchecked`の境界が受入可能である | 未検証 | 非所有Viewの責務と未確定範囲はProfile・公開コメント・監査に明示される。BareArray targetへ`.strictMemorySafety()`を追加して観測中で、buildとtestは成功するが公開7型の警告が残る | 型システムで防げないdangling Viewと並行access、公開7型の`@safe`／`@unsafe`分類、検査省略時の扱いは未評価 |
| QR-04 理解可能性 | 所有・非所有、軸順、初期化、連鎖subscript、writeback、失敗条件を公開文書から理解できる | 確認済み | 現行公開宣言のdocumentation commentをsourceと照合し、BareArrayModuleのDocC生成が成功 | 文書が存在し整合するVerificationであり、一般利用者による理解のValidationは未実施 |
| QR-05 利用可能性 | SwiftPMと`AcCollections`から導入し、対象環境で利用できる | 確認済み | Debug・Release build、facade再公開test 1件、BareArray.swift単独typecheck、DocC生成が成功 | macOSの現行環境における確認。他platform、外部packageとの共存、実利用のValidationは未確認 |
| QR-05 利用可能性 | 競技プログラミングで実用できる | 未検証 | copy & paste許諾と単一file候補はsourceに存在する | 実問題、実提出、実行時間、メモリ使用量のValidation証拠を未確認 |
| QR-06 持続可能性 | 公開面、正確性、寿命、停止契約を変更後に再確認できる | 確認済み | 番号付きTest as Specification 8群、監査記録、Debug・Release・ASan・documentation・performanceを分担するworkflowがある。現行ローカルDebug・Release・ASan・DocCが成功 | workflowの存在とローカル成功から、特定commitのremote CI成功は推定しない。BareArray性能workloadは未登録 |

## 実行記録

- 2026-10-11、`swift test --disable-sandbox --filter BareArrayModuleTests`を実行した。
- XCTestの通常test 35件が成功し、失敗0件だった。
- Swift TestingのDeath Test 42件が成功し、失敗0件だった。
- build時にSwiftPM user cacheへ書き込めない環境警告が出たが、製品buildとtestは成功した。
- `swift test -c release --disable-sandbox --filter BareArrayModuleTests`で通常test 28件とDeath Test 42件が成功した。
- `swift test --disable-sandbox --sanitize address --filter BareArrayModuleTests`で通常test 35件とDeath Test
  42件が成功した。build中のwarningは他moduleの既知testに由来し、BareArrayのSanitizer失敗はなかった。
- `AcCollectionsTests.test_importAcCollections_exposesBareArray`が成功した。
- BareArrayModuleのDocC生成が成功した。
- `BareArray.swift`単独のSwift 6 typecheckが成功した。
- strict memory safetyを指定した単独typecheckは終了コード0だったが、型7件のunsafe storageとunsafe式
  20件、合計27 warningを報告した。旧調査の22箇所は現在値として用いない。
- 評価のフィードバックを受け、BareArrayModule targetへ`.strictMemorySafety()`を追加して観測している。
  採用状態の分類は行っていない。
- allocation、pointer受け渡し、writeback時のpointer比較に明示的な`unsafe` scopeを付け、unsafe式20件を
  解消した。strict typecheckとPackage経路のDebug buildには公開7型の警告だけが残る。
- この変更後も通常test 35件とDeath Test 42件が成功した。
- `Benchmarks/`にBareArray固有のworkloadまたはlibrary登録は見つからなかった。

## 後続task候補

| ID | 種別 | 近さ | 内容 | 必要性 |
| --- | --- | --- | --- | --- |
| `BARE-006` | 既存`DISCOVERY` | `DIRECT` | BareArray 1.0の性能測定設計 | QR-02の外部性能を推定せず、対象操作、size、比較対象、評価方法と必要な判断を整理する |
| `BARE-007` | 既存`EXECUTION` | `DIRECT` | BareArray 1.0の性能計測 | `BARE-006`で確定した構成に従い測定証拠を取得する |
| `BARE-023` | `DECISION` | `DIRECT` | storage境界の扱い | 現行の生ポインタstorage境界を品質検証の前提として維持するか一つだけ決定する |
| `BARE-024` | `DECISION` | `DIRECT` | 公開7型の安全性分類 | 公開所有型4・View型3を`@safe`または`@unsafe`のどちらとして扱うか一つだけ決定する |
| `BARE-025` | `DECISION` | `DIRECT` | strict memory safety採否 | `.strictMemorySafety()`適用状態を品質検証の対象とするか一つだけ決定する |
| `DOC-010` | 既存`DISCOVERY` | `NEAR` | BareArrayの定性的性能表現の再検討 | 実装意図と未測定の外部性能を混同せず、利用者向け表現を再検討する |
| `BARE-017` | `DISCOVERY` | `DIRECT` | BareArray利用Validation scenario設計 | QR-04・QR-05について、一般Swift利用と競技利用の代表scenario、導入経路、観測方法、必要な後続判断を整理する |

`BARE-006`、`BARE-007`、`BARE-023`、`BARE-024`、`BARE-025`、`DOC-010`の凍結は本評価によって解除しない。
`BARE-017`は判断を確定せず、一般利用と競技利用で実行・判断境界が異なる場合は後続taskへ分離する。

## Viewノンエスケーパブル化

- ID: `BARE-018`
- 種別: `EXECUTION`
- 担当: Codex
- 現在の中間ゴールへの近さ: `DIRECT`

View 3種を`~Escapable`化し、所有元から返すinitializerと多段subscriptへ必要なlifetime dependencyを
追加する。BareArrayのViewは、所有storageを複製せず部分領域を参照する非所有・ノンコピーViewとして
設計されている。通常の`Escapable`な値のままでは所有元を越える保持を型システムで拘束できず、
安全性のために所有化するとノンコピーという設計目的が崩れる。そのため、`~Escapable`化は今回新たに
採否を検討する案ではなく、Swift 6.4の提供まで実装を待っていた既定方針である。

Swift 6.4のLifetimes実験機能を用い、compilerがViewの所有元越えを拒否すること、多段subscriptと
writebackが成立すること、および既存testへの影響を確認する。コンパイル時拒否へ移る既存契約は、
実行時Death Testから適切なcompiler診断のVerificationへ移す。

このtask自体では公開型の`@safe`／`@unsafe`分類を確定しない。ただし、その分類、storage境界、
strict memory safetyの採否はいずれも品質検証を再開する前提であり、完了後へ先送りしない。

### 完了条件

- View 3種が`~Escapable`となり、所有元と多段Viewに必要なlifetime dependencyが過不足なく付いている。
- 対応する既存subscript、連鎖アクセス、およびwritebackの有効な利用がDebug・Releaseで成立する。
- 所有元を越える保持などの無効な利用がcompiler診断で拒否され、そのVerification方法が定まっている。
- コンパイル不能となったDeath Testを、compiler診断による検証、残すruntime test、または失効したtestへ
  棚卸しし、単に`#if false`で退避した状態を残さない。
- 現在の途中差分を整理し、既存契約への影響と未確認範囲を記録する。

### 2026-10-11 途中結果と再停止点

- View 3種の`~Escapable`化、所有元をborrowするinitializer、親Viewのdependencyをcopyするinitializer、
  および多段subscriptのlifetime dependencyを追加した。
- BareArrayModuleのproduction moduleはSwift 6.4のLifetimes実験機能下でcompileできた。
- 既存testの`array[2] = array[1]`は、右辺Viewが所有元をborrowしている間に左辺setterが同じ所有元へ
  排他accessするため、compilerがoverlapping accessとして拒否した。
- 従来はこの式をcompile可能とし、実行時にwriteback位置違反で停止するDeath Testだった。拒否契約は
  変わらず、Verification手段だけが実行時Death Testからコンパイル時診断へ移ったと確認したため、
  一時作成した判断task `BARE-019`は製品判断ではないものとして除外した。
- この作業中にユーザーが直接sourceを修正した時点で実装を停止し、差分を正式実装の途中状態として
  保存した。その後、ユーザーの明示的な再開指示を受けてtask graphを再構成し、分割taskから再開した。
- 会話中の事実訂正、既存契約の確認、暫定的な`#if false`、および製品判断を区別する。相互の勘違いを
  訂正した発言やVerification手段の変化を、新しい製品判断として登録しない。
- View 3種を`~Escapable`とし、所有配列のsubscript resultは所有元をborrow、多段Viewのsubscript resultは
  親Viewのdependencyをcopyする途中実装がある。BareArrayModuleのproduction compileは成功した。
- 独立したcompile-fail fixtureを2つ追加し、所有元を越えてViewを返す3件が
  `lifetime-dependent value escapes its scope`、所有配列の同時read/write 3件がoverlapping accessとして
  拒否されることを検証した。
- 所有配列writebackの3件をDeath Testからcompiler診断fixtureへ移し、暫定的な`#if false`を解消した。
  残るDeath Test 39件はDebug・Releaseの両構成で成功した。
- 通常testはDebug 35件、Release 28件が成功し、facadeからのBareArray公開testも両構成で成功した。
- strict memory safetyの公開7型warningは残る。この分類を含め、今回の途中実装と検証を正式成果として
  受け入れるかは確定していない。
- 実装と局所検証の成功をもって品質評価上の完了まで進めたのは先取りだったため、`BARE-018`と分割taskを
  凍結した。storage、公開型の安全性分類、strict memory safetyを独立した並行前提として閉じた後、
  ユーザーが品質検証の再開を判断する。

### 再開までのtask graph

`BARE-018`は個別実装を抱えるtaskではなく、分割した成果の受入と評価記録を閉じる完了ゲートとする。
品質検証の再開前に、storage、公開型の安全性分類、strict memory safetyを独立した並行系統として閉じる。
View寿命はノンエスケーパブル化と同一の論点であり、独立taskを作らない。

| ID | 種別 | 内容 | 完了条件 |
| --- | --- | --- | --- |
| `BARE-020` | `EXECUTION` | View 3種、lifetime dependency、Package設定の整合化 | 現在の途中差分を必要最小限の正式実装へ整え、production moduleがcompileする |
| `BARE-021` | `EXECUTION` | compiler診断Verificationへの移行 | 所有配列writeback Death Test 3件を棚卸しし、暫定的な`#if false`を残さない |
| `BARE-022` | `EXECUTION` | 有効利用経路の回帰確認 | subscript、連鎖アクセス、View、writebackの有効な利用がDebug・Releaseで成功する |
| `BARE-023` | `DECISION` | storage境界の扱い | 品質検証の前提として現行storage境界を維持するか一つだけ決定する |
| `BARE-024` | `DECISION` | 公開7型の安全性分類 | 公開所有型4・View型3の`@safe`／`@unsafe`分類を一つだけ決定する |
| `BARE-025` | `DECISION` | strict memory safety採否 | `.strictMemorySafety()`適用状態を品質検証の対象とするか一つだけ決定する |
| `BARE-026` | `DECISION` | 品質検証の再開判断 | 3系統の決定後、保存した途中成果を対象として品質検証を再開するか一つだけ決定する |
| `BARE-027` | `EXECUTION` | ノンエスケーパブル化の品質検証 | 確定した前提でVerification、Validation、残余リスク、未検証領域を評価する |
| `BARE-018` | `EXECUTION` | 完了ゲート | 分割成果を受け入れ、既存契約への影響と未確認範囲を本書へ記録する |

storage、安全性分類、strict memory safetyの3系統を`PARALLEL_JOIN`で品質検証の再開判断へ合流させる。
再開が決定した場合だけ品質検証を実行し、その結果を`BARE-018`の完了判定へ渡す。storage再設計などの
後続作業は現在の必須経路へ置かず、必要性が実際に発見された時点で別taskとして整理する。

2026-10-11、`BARE-020`、`BARE-021`、`BARE-022`には実装・診断・回帰確認の途中証拠が揃ったが、
成果の受入と`BARE-018`への合流は確定していない。storage、安全性分類、strict memory safetyの
3系統と品質検証の再開判断を経るまで、関連taskを凍結する。
