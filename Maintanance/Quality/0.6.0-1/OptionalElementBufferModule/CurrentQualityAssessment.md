# OptionalElementBufferModule Current Quality Assessment

## 文書の役割

この文書は、OptionalElementBufferModuleの0.6.0時点の現行品質評価を記録する。
上位品質要求は`Maintanance/Quality/QUALITY_REQUIREMENTS.md`、モジュールへの適用と証拠境界は
`Sources/OptionalElementBufferModule/Documentation/Quality-Profile.md`を正本とする。
体系監査と過去の判断は`OptionalElementBufferAudit.md`を参照するが、旧評価の判定は継承しない。


> 2026-10-16、進捗表示を整理。以下の評価日・実行結果・当時の型名は、その時点の記録として保持する。現在の作業状態は[Task Registry](../../../ProgressV2/TASK_REGISTRY_V2.md)、提供方針は上記の品質要求・Quality Profileを参照する。

## Task

- 種別: `DISCOVERY`
- 担当: Codex
- 現在の中間ゴールへの近さ: `DIRECT`
- 評価日: 2026-10-13

現在の状態、ID、担当、および依存はTask Registryを正本とする。

## 目的

現行source、Test as Specification、Package設定、CI、公開経路、および実行結果を上位品質要求へ
対応付け、次を区別する。

- 確認済み
- 未達
- 未検証
- 対象外
- 受容済みの残余リスク

判断に見える不足は、事実不足、依存未整理、既存契約の適用で解消できるかを先に確認する。
それらで結論が導ける偶有的判断を、ユーザー判断taskとして残さない。

## Quality Profile現在性

現行Quality Profileは、所有4型、番号付きTest as Specification、性能証拠、`Sendable`、
strict memory safety、`-Ounchecked`の境界を扱う。2026-10-13、deprecatedだった連鎖subscriptと
非所有View 3型を削除し、座標access methodだけを現行要素accessとした。

## 現行評価

| 上位要求 | 品質主張 | 評価 | 現在の証拠 | 未確認範囲・残余リスク |
| --- | --- | --- | --- | --- |
| QR-01 正確性 | 初期化、nil状態、次元、offset、座標access、`removeAll()`、破棄が公開契約どおり動作する | 確認済み | 1D〜4Dの座標accessを非対称shape全座標、選択位置だけの更新、値・nil遷移、参照要素のexactly-once破棄、全軸boundsで直接仕様化。削除後の56 testが成功 | 有限な型、寸法、操作列によるVerificationであり、任意入力の証明ではない |
| QR-02 性能効率性 | presence mapとpayloadの連続storage、O(1) access、線形初期化・破棄という実装特性が公開説明と一致する | 確認済み | sourceとdocumentation commentを照合。要素accessは定数回のoffset計算、初期化・`removeAll()`・破棄はcapacityに比例する | 実装構造上の計算量であり、実行時間、allocation cost、最適化結果を証明しない |
| QR-02 性能効率性 | 利用目的に対する外部性能が十分である | 未検証 | 2D・3Dのcold / warm memoization benchmarkはCIへ登録済み | C++ nested vector番兵版との外部比較結果と性能比の受入水準は未確定 |
| QR-03 安全性 | storage確保・要素寿命・範囲・次元が検証した経路で成立する | 確認済み | ASanを含むremote CIが成功。現行座標accessについて参照要素の置換・nil遷移と、1D〜4D全軸の負値・上限に対するread / write trapを直接仕様化した | ASanと有限のtest経路で観測できないunsafe操作の正しさまでは証明しない |
| QR-03 安全性 | strict memory safety下で公開APIとunsafe境界が成立する | 確認済み | 所有4型を`@safe`に分類し、低レベル操作をscoped `unsafe`へ限定。targetへ`.strictMemorySafety()`を恒久適用し、Build for Testingと削除後の56 testが成功 | strict設定はunsafe実装自体の正しさを証明せず、境界の明示と未注釈操作の検出を提供する |
| QR-03 安全性 | `@unchecked Sendable`が許す移送・共有の範囲が妥当である | 未検証 | 所有4型に条件付き適合がある。compile testは1Dのみ | 2D〜4Dの表面確認、移送後の所有、並行共有・data raceの意味的Validationは未実施 |
| QR-03 安全性 | `-Ounchecked`で省略される事前条件との境界が受入可能である | 未検証 | 公開コメントは検査省略可能性を明示する | `-Ounchecked`構成の実行、範囲・次元違反時の扱いは評価していない |
| QR-04 理解可能性 | nil状態、座標と軸順、`removeAll()`、失敗条件を公開文書から確認できる | 確認済み | 現行公開面のdocumentation commentを実装と照合済みで、過去にDocCをwarnings-as-errors付きで生成できた | 削除後のDocC再生成と、一般利用者が誤解なく使えることのValidationは未実施 |
| QR-05 利用可能性 | traitを選んだ競技用途で`AcCollections`再公開経路を利用できる | 確認済み | `ENABLE_OPTIONAL_ELEMENT_BUFFER`付きfacade test、OptionalArrayModule専用test、Benchmark package buildが現行macOS環境で成功 | 一般Swift向け既定提供は取り下げ。repository外consumerと他platform・toolchainは新しいtrait境界で未確認 |
| QR-05 利用可能性 | 競技プログラミングで実用できる | 未検証 | EDPC-J・EDPC-Lはtest targetのcompile evidenceであり、単一file利用許諾もsourceにある | 正答、実提出、実行時間、メモリ使用量は確認していない |
| QR-06 持続可能性 | 変更後に公開面、状態、寿命、次元、停止契約を再確認できる | 部分確認 | 番号付きTest as Specification、座標access直接仕様群、Debug・Release・ASanのCI job、および2D・3D memoization accessの回帰workloadがある。これらを含むPR #192のremote CIはall greenで、OptionalArrayModuleのDocC生成も個別に成功した | CIのDocC対象にOptionalArrayは含まれず、documentation commentの変更後もDocC生成を継続して再確認できる自動経路はない |

## 実行記録

- `swift test --disable-sandbox --filter OptionalArrayModuleTests`: 通常test 35件、Death Test 26件成功。
- `swift test -c release --disable-sandbox --filter OptionalArrayModuleTests`: 通常test 35件、Death Test 26件成功。
- `swift test --disable-sandbox --sanitize address --filter 'OptionalArray_'`: 通常test 35件、Death Test 26件成功。
- `AcCollectionsTests.test_importAcCollections_exposesOptionalArray`: 1件成功。
- `swift package --disable-sandbox generate-documentation --target OptionalArrayModule --warnings-as-errors`: 成功。
- `swift build --disable-sandbox --target OptionalArrayModule`: 成功。
- `swiftc -typecheck -swift-version 6 -enable-experimental-feature Lifetimes -strict-memory-safety`による
  単独typecheck: warning 0、error 0。
- `.strictMemorySafety()`恒久適用後のXcode Build for Testing: 成功。
- Xcode Build for Testing成功。削除後の`OptionalArrayModuleTests`は通常35件、Death Test 21件の
  合計56件が成功し、失敗0件。
- BenchmarkのRelease buildに成功。2D・3Dのcold / warm memoization checksum 4件をsize 1・3・16で
  3反復し、全件のchecksum検証に成功。
- `Benchmarks/Libraries/CI.json`は30 task・60 size・最大64kを70.4秒で完走。OptionalArray 4件を
  通常CI libraryの選択対象として実行した。
- candidate `215be94b`をlocal path dependencyにしたrepository外SwiftPM consumerをApple Swift 6.4、
  macOS 27.0.1、arm64、debugで実行。直接module import、`AcCollections`再公開、`PermutationModule`との
  共存の3 executableがbuild・runに成功した。多次元の内側寸法はpublic propertyから取得できず、consumerが
  shapeを保持する必要があることを理解可能性の観測候補として残した。

SwiftPM user cacheが書込み不可である環境警告と、ASan build時にOptionalArray testの`var` 1件、
RedBlackTree testの未使用値2件のwarningが出た。製品OptionalArrayModuleの通常buildにはwarningがない。

## 多次元access性能測定設計

OptionalArrayの競技用途であるmemoizationを表すため、2Dと3Dのそれぞれで次の2状態を測定する。

- cold access: 未設定slotを読み、未設定なら線形indexと同じ値を保存し、保存値をchecksumへ加える。
- warm access: 同じ値で事前に全slotを設定し、設定済み値の読み取りだけをchecksumへ加える。

shapeはBareArray測定と同じ総要素数の素因数を各軸へ均衡に割り当て、積が入力sizeと完全に
一致する2D・3D shapeを用いる。走査は最内軸から連続する順序とし、期待checksumは
`size * (size - 1) / 2`とする。

配列の確保、shape計算、warm状態の事前設定は計測外に置く。計測内には座標accessによる
presence確認、cold時の値保存、値取得、checksum更新だけを含める。checksumは計測後に
`blackHole`と`precondition`へ渡し、最適化による消去と誤った走査を検出する。

CIにはSwift版の4 workloadだけを通常libraryへ登録する。後続のC++外部assessmentでは、
nested `vector<Int>`を同じshapeで確保し、未設定を表す番兵値をpresence判定に用いて、
同じcold / warm操作、走査順、checksumに対応させる。C++ workloadは通常CIには含めない。

## 現行座標access Test as Specification監査（2026-10-13）

削除前に連鎖subscript・非所有Viewの互換testと、現行`element`／`setElement`の仕様証拠を
分離して確認した。座標methodの既存testは1D〜4Dで各1座標のnil→value→nilと近傍1点を確認するが、
次は未検証だった。

- 非対称shapeの全座標を通した軸順・stride。
- 選択座標だけが変更され、各軸の近傍が変化しないこと。
- direct `setElement`による参照要素の上書きとnil遷移で、旧要素がちょうど一度破棄されること。
- 1D〜4Dの各軸について、`element`と`setElement`が負値と上限値をSwift trapで拒否すること。

これらは既存の次元、座標順、範囲、要素所有契約から直接導け、新しい製品判断を要しない。
旧Viewの寿命・writeback仕様は削除した公開面だけの契約なので、現行座標accessの証拠へ転用せず退役させた。

上記不足を現行API専用のtestへ実装した。非対称shapeの全座標を1D〜4Dで読み書きして軸順とstrideを固定し、
各軸の近傍が未設定のままであること、参照要素の置換とnil化が各値をexactly onceで破棄することを確認する。
Death Testは1D〜4Dの全軸について、負値と上限値をread・writeの双方で与え、Darwinでは`SIGTRAP`、
Linuxでは`SIGILL`というSwift preconditionのsignalまで固定した。2026-10-13にBuild for Testingが成功し、
追加した通常test 3件とDeath Test 8件を含む削除後のOptionalArray全56件が成功した。

### C++番兵workloadと暫定チャート

Swift版と同じexact-productの2D・3D shape、最内軸からの連続走査、cold / warm状態、
checksumに対応するC++ nested `std::vector<intptr_t>` workloadを4件追加した。C++側は`-1`を
未設定slotの番兵とし、coldでは計測前に全slotを番兵へ戻し、warmでは計測前に線形index値を
全slotへ設定する。通常CI libraryには含めず、`OptionalArrayAssessment.json`の専用libraryから
だけ選択する。

Release build後、OptionalArray / Swift nested Array番兵 / C++ nested vector番兵の合4件をsize 1・3・16で
3反復し、checksum検証を含め成功した。さらに12 workloadをsize 1から64kまで60 size・5 cycle実行し、
生JSONと3系列を含む4枚のPNGを
`Benchmarks/QualityAssessment/macOS/OptionalArray/`へ暫定証拠として保存した。この結果は
比較経路と可視化の成立確認であり、性能比の受入判断または正式assessmentではない。

## `Sendable`契約の根拠確認（2026-10-13）

所有4型は`Element: Sendable`のとき条件付き`@unchecked Sendable`へ適合する。適合はcommit
`9b100953`（2026-06-10）で追加されたが、commit messageは`sendable`だけで、採用理由、
安全性を成立させる不変条件、および許可する並行利用境界は履歴に記録されていない。

今回ユーザーへ確認した製品上の目的は、これらをthread-safeな共有containerにすることではない。
TopLevelを実利用のentry pointとしたときにMainActor等のconcurrency domain境界が生じるため、
所有値をその境界越しに扱えない不便を解消することである。同一instanceへの無同期な並行accessは
保証対象にせず、利用者が避ける範囲とする意図である。

一方、Apple Swift 6.4の`Sendable`文書は、値を任意の並行contextで共有してもdata raceの危険を
導入しないtypeと定義し、共有mutable stateを持たないか、lockまたはactor isolationで保護することを
求めている。`@unchecked Sendable`はcompiler検査を省略するが、この意味上の要求を弱めるものではなく、
適合の正しさは実装側の責任になる。

現行4型は`~Copyable`であるためcopyによるstorage aliasは作らない。しかし`setElement`と
`removeAll()`は、wrapper自身のstored propertyを変更せずraw pointerのpointeeを変更する
nonmutating methodである。Swift 6.4のstrict concurrencyによる一時compile probeでは、4型が
`Sendable & ~Copyable`制約を満たし、actorへのconsuming transferがcompileすることを確認した。
同時に、同じ1D instanceを二つの`async let`へborrowし、双方から`setElement`を呼ぶコードも診断なしで
compileした。これはdata raceの実行を確認した結果ではないが、`~Copyable`と現行method表面だけでは
共有borrowからの並行更新を型システムが拒否しないという反証である。

したがって、現在の証拠から`Sendable`適合を削除するとも、現状のまま正当化できるとも判断しない。
製品上必要なdomain間移送を維持しつつ、同一storageの並行更新を型・所有権で禁止できるか、または
別の成立条件が必要かを先に調査する。単に「thread-safeではない」「並行accessは利用者責任」と
説明するだけで、Swiftの`Sendable`が持つ意味上の要求を満たしたとは扱わない。

### 両立可能性の独立probe

ClaudeがSwift 6.4で`-strict-concurrency=complete -wmo -emit-sil`を使い、現行相当の最小模型を
独立検証した。`-typecheck`だけではownershipとregion isolationの拒否診断が出ないため、Codexの
初回probeが「`mutating`化でも通る」とした観測は検証段階不足であり、撤回する。

確認した範囲では、`@unchecked Sendable`を維持して`setElement`と`removeAll()`を`mutating`にする
候補だけが、actor・MainActorへのconsuming transfer、actor storageからの再移送、並行読み取りを
維持しながら、二つの`async let`または`Task`からの並行更新と、並行読み取り中の親側更新を拒否した。
一方、呼出側は更新対象を`let`ではなく`var`で宣言する必要がある。

`Sendable`を外してregion isolationまたは`consuming sending`に移送を委ねる候補も、actorへの単純な
consuming transferは成立した。しかしactorのstored propertyからの再移送と並行読み取りを失い、
`Sendable & ~Copyable`を要求するgeneric APIへ渡せなくなる。現行のままでは、同じlocalへの三つの
共有更新経路が診断なしで成立する。

この結果は最小模型のcompiler behaviorであり、実装採用判断ではない。`mutating`候補が依存する
「pointeeへの書込みはmutating methodとdeinitだけで、pointerは非公開」という不変条件を現行4型で
照合し、既存呼出側へのsource影響を棚卸ししてから、適合維持方法を一判断へ分離する。

### `mutating`候補のsource影響棚卸し

Claudeが1D〜4Dの`setElement`と`removeAll()`を`mutating`にした模型をSwift 6.4のSIL生成まで確認し、
repository内の呼出しを棚卸しした。既存sourceを変更せず、次を確認した。

- test・facade test・benchmarkの23箇所は、receiverを`let`から`var`へ変える機械的影響である。
- death testの一時値receiver 20箇所は、localの`var`へ受けてから呼ぶ形への書換えを要する。
- 既に`var`の呼出し、更新しない`let`、EDPC例の`nonisolated(unsafe) var` captureは、確認した模型では
  `mutating`化後も成立する。
- benchmarkのescaping closureがcaptureする`var`はbox化・exclusivity検査により計測値へ影響し得るため、
  実装時には性能回帰と計測形変更を分離して確認する必要がある。
- repository外では、`let`、`borrowing`引数、一時値receiverからの更新がsource incompatibilityになる。
- Swift 6 modeのトップレベルでは、現行の`let`をトップレベル関数から更新する形が成立しても、
  `mutating`化に伴う`var`はMainActor隔離となり得る。nonisolated関数から更新するには
  `nonisolated(unsafe) var`が必要になることを最小probeで確認した。Swift 5 modeでは`var`化だけで通った。

したがって、repository内の修正量だけを根拠に機械的変更とは扱わない。domain間移送と並行更新拒否を
両立する利点に対し、Swift 6の競技用トップレベルコードを含むsource compatibilityを受容するかを、
実装とは別の製品判断とする。

ユーザーは、この差異を新しい互換性方針の選択ではなく、更新methodへの`mutating`指定漏れの修正と
判断した。1D〜4Dの`setElement`と`removeAll()`へ`mutating`を付与し、repository内の呼出側を
mutable bindingへ追従させた。条件付き`@unchecked Sendable`は維持する。Xcode Build for Testing、
全test（1475 passed、0 failed、256 not run）、Benchmark packageのrelease buildが成功した。

### `mutating`追従後のperformance CI回帰

上記変更後のremote performance CIで、OptionalArrayの2D・3D direct cold / warm 4 workloadに
54〜64%の見かけ上の性能低下が生じた。製品実装の性能回帰と即断せず、事前棚卸しでClaudeが記録した
「escaping closureがcaptureする`var`はbox化・exclusivity検査により計測値へ影響し得る」という
予測とbenchmark sourceを照合し、最初の原因仮説とした。

`mutating`追従時にbufferのbindingを外側のbenchmark factory closureで`var`へ変更したため、返却する
計測closureからescaping captureされていた。buffer生成を返却closure内へ移し、cold / warmの準備は
従来どおり`timer.measure`の外側に維持した。freshなbufferは全slotがnilであるため、cold側に追加されて
いた計測前の`removeAll()`は不要として除いた。これにより計測対象のaccess操作は変更していない。

修正後、Benchmark packageのrelease buildに成功した。専用libraryの全workloadをsize 1〜64k、1 cycleで
実行し、checksumを含め完走した。しかしremote CIでは4件に31〜49%の回帰が再び出たため、escaping captureを
原因として確定した判断を撤回する。

同じmacOS machine・Apple Swift 6.4・Release・専用library・最大64k・1 cycle・`replace-all`で、変更前
`01120025`と修正後を別buildして比較した。修正後は4件すべて約10〜25%改善し、30%回帰は0件だった。
したがってmacOSではCIの回帰を再現できず、履歴bisectの前提を満たさない。Linux CI artifactに保存された
実測binary、assembly、CPU、toolchain、base / head JSONを照合し、命令列差、配置差、環境差を切り分けるまで、
製品実装またはbenchmark harnessのいずれを原因とも確定しない。

### Linux CI境界比較と提供範囲の再判断（2026-10-14）

manual performance CIで同一runner上の三境界を比較した。`a1c51a2`から`13f23f0b`への
`mutating`化では、2D・3D direct cold / warmの4 workloadが1.640〜2.304倍遅くなった。
`13f23f0b`から`215be94b`へのescaping capture除去では4件すべてが1.189〜1.372倍改善したが、
変更前`a1c51a2`と最終`215be94b`の直接比較では1.354〜1.720倍の回帰が残った。
したがって、`mutating`化が回帰境界で、capture除去は部分回復である。

この結果と利用目的を再確認し、現行split storage実装を一般Swift向けの既定提供として性能回帰付きで
維持しない。`OptionalElementBuffer`は当面、競技プログラミング等で明示的に選ぶ低レベル部品として
`ENABLE_OPTIONAL_ELEMENT_BUFFER` traitによるopt-in提供へ下げ、1D〜4Dの`setElement`と
`removeAll()`をnonmutatingへ戻す。`Sendable`をthread-safe containerの保証とは扱わず、
domain間移送上の必要性と同一instanceの並行更新を利用者が避ける境界は残る。

Swift 6.4以降向けに、split storageを維持するか、`Element?` storageと標準`MutableRef`を利用する
一般提供方式へ再設計するかは別の凍結調査とする。現在の判断から将来方式や性能を確定しない。

実装後、trait無効のXcode Build for Testing、trait有効のfacade再公開test、OptionalArrayModuleの
通常35件とDeath Test 21件、Benchmark packageのrelease buildが成功した。問題となった2D・3Dの
direct cold / warm 4 workloadもsize 16・256・4096、3 cyclesで完走した。この短縮実測は実行経路の
確認であり、正式な性能assessmentや旧commitとの性能比判定ではない。

## 判断の整理

- 1D所有型名は横断命名判断でunsuffixedの`OptionalElementBuffer`に確定し、実装反映も完了した。
  次元名体系も同じ判断で現行維持に確定しており、旧`OPT-045`を0.6.0到達範囲判断の前提に残さない。
- 旧31診断という評価は現行sourceに対して失効した。再取得した40件は、所有型分類4件、allocation
  境界8件、deprecated View経路28件へ分離でき、製品判断を追加せず警告0件へ整理できた。
- deprecatedだった連鎖subscriptとViewを削除し、利用例・test・benchmarkを座標accessへ移行した。
- 性能、一般利用、競技利用、`-Ounchecked`は証拠不足であり、成功とも失敗とも判断しない。
- `Sendable`はdomain間移送上の必要性から維持する。一方、現行の共有borrowとnonmutatingなstorage更新は
  並行更新を型で拒否しないため、thread-safe containerとして一般提供する根拠にはしない。
- 現行split storage実装は`ENABLE_OPTIONAL_ELEMENT_BUFFER` traitによるopt-in提供へ下げ、更新APIを
  nonmutatingへ戻す。Swift 6.4以降向け一般提供方式の再設計は凍結する。
- 多次元accessの測定条件は、OptionalArrayの既存用途とBareArrayで確定済みのshape・計測境界から
  導ける。新しい製品仕様や性能比の受入水準を決めないため、設計時のユーザー判断は発生しない。

### 外部性能判定taskの見直し（2026-10-14）

現行split storage実装は一般提供から外れ、`ENABLE_OPTIONAL_ELEMENT_BUFFER` traitによる実験的な
opt-in提供になった。この提供区分では、1.0適合判定のためにC++番兵workloadとの固定性能比を先に
決め、正式assessmentを実行する必要はない。このため`OPT-053`と`OPT-054`を`EXCLUDED`とする。

外部性能が確認済みになったという意味ではない。既存の暫定測定、保存artifact、CI回帰workloadは
現行実装の性能証拠として保持する。将来、一般提供方式を再検討する場合は、当時の実装、利用目的、
workload、比較対象に基づいて新しい評価を設計し、今回の固定閾値taskを再利用しない。

## 後続task候補

| 種別 | 近さ | 内容 | 境界 |
| --- | --- | --- | --- |
| 既存`DECISION` | `DIRECT` | 次元名体系 | 品質評価とは独立した公開名称だけを扱う |
| 既存`DISCOVERY` | `LATER` | 1.0前の品質再評価 | ユーザードキュメント完了後、性能と利用Validationを含む1.0不足を再評価する |

## 結論

0.6.0時点の現行品質アセスメントは完了した。正確性、検証したメモリ経路、公開説明、package利用経路、
回帰構造とstrict memory safetyには現行証拠がある。一方、`Sendable`にはdomain間移送の必要性と
共有borrowからの並行更新を拒否できない反証の双方があり、成立方法は未決である。`-Ounchecked`、
外部性能、一般利用・競技利用のValidationも未検証である。
