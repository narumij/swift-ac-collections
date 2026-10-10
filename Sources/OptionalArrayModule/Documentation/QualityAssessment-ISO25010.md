# OptionalArrayModule 品質評価（ISO/IEC 25000シリーズ観点）

> 状態: 初版完成（2026-10-08）。利用者向け文書作業後に再評価する。
> 評価対象: `Sources/OptionalArrayModule/OptinalArray.swift`の公開7型・公開宣言29件と公開適合4件。

## 1. 目的と評価方法

OptionalArrayを競技プログラミング用の低レベル公開部品として利用者向け文書へ渡す時点で、
ISO/IEC 25010:2023の製品品質9特性から、確認済みの品質、根拠、不足を初版として整理する。
利用時の品質は主な利用文脈と既存利用例の範囲だけを扱う。

判定はPermutationModuleの品質評価と同じく、`満たす`、`部分`、`未評価`、`対象外`を使う。
Test as Specificationと体系監査を仕様・証拠の正本とし、本書では仕様を再定義しない。

## 2. Claude証拠収集の共通境界

- 既存source、test、Package設定、CI、体系監査、git履歴から確認できる事実だけを記録する。
- 品質特性の判定、1.0前に必要な改善、公開契約、利用者向け文書の内容を決めない。
- production code、test、Package設定、CI、他文書を変更しない。
- 根拠はfile、test名、設定、commitのいずれかへ具体的に対応させ、未確認を推測で埋めない。
- 新しいdefect、ユーザー判断、公開契約変更が必要な事項を見つけた場合は、根拠を記録して停止する。
- 各担当は自分の節だけへ結果を追記し、Codexの評価欄や他担当の節を変更しない。

## 3. 製品品質の証拠

### 3.1 機能適合性・信頼性・安全性

担当: Claude。公開契約表、番号付き仕様test、Death Test、境界・寿命・次元の証拠を使い、次を表にする。

- 特性・副特性
- 確認できる事実
- 根拠
- 未検証範囲
- 評価時に区別すべき前提

安全性は人命・財産・環境への危害という品質モデル上の意味で扱い、メモリ安全性はセキュリティ節と
混同しない。評価語は付けない。

#### 3.1 Claude証拠（OPT-039、2026-10-08）

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。HEAD `ad82f4e7`。`L<n>`は`OptinalArray.swift`の現行行。
`Audit OPT-0xx`は`Maintanance/OptionalArrayModule/OptionalArrayAudit.md`の同名節（行番号は`85e60200`時点のもの）。
testは`Tests/OptionalArrayModuleTests/`のfile名・test名で示す。新しい実行は、本日のOPT-036で行ったDebug／Releaseの`swift test --filter OptionalArrayModuleTests`だけ。

| 特性・副特性 | 確認できる事実 | 根拠 | 未検証範囲 | 評価時に区別すべき前提 |
| --- | --- | --- | --- | --- |
| 機能適合性・機能完全性 | 公開7型・公開宣言29件と公開適合4件（所有4型の条件付き`@unchecked Sendable`）がledgerに一度ずつ対応している。公開面は初期化、要素の取得・設定・`nil`代入、`removeAll()`、`indices`、Viewによる部分参照だけ | Audit OPT-015（ledger）、Audit「公開契約表」、L100 / L188 / L270 / L359 | 公開面に無い操作（`count`、`isEmpty`、列挙、`Equatable`など）を利用者が必要とするかは記録が無い | 公開位置づけは「競技プログラミング用の低レベル公開部品として1.0でも公開継続」（OPT-029）。機能の過不足はこの用途を基準にする |
| 機能適合性・機能正確性 | 初期nil、取得・設定・nil代入、Viewのstorage共有、非対称次元のstride、`indices`の軸、`removeAll()`、zero dimensionが仕様testで固定されている。2D〜4Dの座標→offsetは机上と一時実行で全単射を確認済み。3DViewの面strideは`89a93f9d`で修正、4D zero-volumeの外側subscriptは`244c6083`で修正 | `OptionalArray_1_`〜`_5_`（計26件）、Audit OPT-020、OPT-034実施結果 | 所有2D・3D・4Dの行／面／立方体strideのalias検出testは無い（Audit OPT-020）。Viewの上端書込みなど一部の境界はtestが無い（Audit OPT-018） | 仕様testがあるのは公開契約の成功側。境界の停止側は次行の信頼性で扱う |
| 機能適合性・機能適切性 | 未設定状態を`nil`で表し、番兵値なしにメモ化できることが型のコメントで述べられている（L15〜L20）。EDPC-J（3D）・EDPC-L（2D）が実利用形状をcompileする | L15〜L20、`EDPC-J.swift`、`EDPC-L.swift`、Audit OPT-023 | EDPC利用例は呼ばれず、期待値は実行で確かめていない（Audit OPT-023、引き渡し判定節） | 適切性は用途（メモ化DP）に対するもので、汎用配列としての適切性は対象にしていない |
| 信頼性・無欠陥性 | 次元は各軸`>= 0`かつ積が`Int`で表せることを`precondition`で検査（L29、L131〜L133、L206〜L213、L289〜L297）。添字は全経路が`precondition`。Death Test 21件（境界8、次元13）がmacOSのDebug・Releaseで成功（本日OPT-036で実行） | `OptionalArray_99_DeathTests.swift`、Audit OPT-033実施結果、OPT-036・037実施結果 | Death Testは`processExitsWith: .failure`で、停止理由を区別しない（OPT-033実施結果）。1D所有の上端書込み、2D〜4D所有の外側、1DView・2DViewの上端は停止testが無い（Audit OPT-018）。Linuxでは`DEATH_TEST`が既定で定義されず、CI（ubuntu-24.04）のdebug / release jobでは実行されない（`Package.swift:82-83`、`.github/workflows/ci.yml`） | 停止は`precondition`によるので、`-Ounchecked`では検査自体が消える（Audit OPT-018の一時実測）。`-Ounchecked`での次元検査（OPT-033で追加）も、`precondition`である以上同じく消える（コード上の事実。OPT-033後は実行していない） |
| 信頼性・可用性／耐障害性／回復性 | 契約違反はprocess停止で、回復可能なerrorを返すAPIは無い | 公開宣言（Audit OPT-015）にthrowsや`Result`が無い | — | 低レベル部品で契約違反を停止扱いにする設計の是非は、評価側の読み替えに属する |
| 信頼性（参照型要素の寿命） | 上書き1回、設定済みへのnil代入1回、`removeAll()`は設定済み件数、再利用後とdeinitは残存件数だけ破棄されることを、8件のtestが参照型の`deinit`回数で固定している | `OptionalArray_6_ReferenceLifetimeTests.swift`、Audit OPT-019 | 未設定slotへのnil代入（破棄0回）、1Dの再利用・残存deinitはtestが無い（Audit OPT-019） | 破棄回数の検証は単一threadのtest内だけ |
| 安全性（ISO/IEC 25010の危害の意味） | OptionalArrayは人命・財産・環境に作用する機能を持たないメモリ上のcollectionで、安全性に関わる操作制約や危害警告の記載は無い | source全体、利用者向け文書は未作成 | 利用者のsystemへ組み込まれた場合の危害は、この部品の範囲では観測できない | メモリ安全性（範囲外access、View寿命、`@unchecked Sendable`）は3.3のセキュリティで扱い、ここに数えない |

停止事項: 新しいdefect、ユーザー判断、公開契約変更が必要な事項は見つからなかった。`-Ounchecked`で検査が消える件は、既にCodexが`OPT-008`の境界契約・安全性論点として受け取っている（Audit「Codex evidence intake」）。

### 3.2 性能効率性・互換性・柔軟性

担当: Claude。既存benchmark、計算量の記載、SwiftPM構成、platform、他moduleとの再公開・同時利用、
対応する既存testを調べ、3.1と同じ列の表にする。新規benchmarkや性能推定は行わず、測定根拠がなければ
未評価候補として事実だけを記録する。

#### 3.2 Claude証拠（OPT-040、2026-10-08）

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。HEAD `ad82f4e7`。略記は3.1と同じ。新規計測はしていない。

| 特性・副特性 | 確認できる事実 | 根拠 | 未検証範囲 | 評価時に区別すべき前提 |
| --- | --- | --- | --- | --- |
| 性能効率性・時間効率性 | OptionalArrayのbenchmarkは無い。`Benchmarks/`のtracked fileにOptionalArrayの名前は出てこず、performance jobが使う`Benchmarks/Libraries/CI.json`にも入っていない。testにperformance API（`measure`）は無い | `git grep OptionalArray -- Benchmarks`（0件）、Audit OPT-035前提、OPT-034実施結果 | 実行時間の測定根拠は無い | 未評価候補。OPT-034で4D外側subscriptのgetterに分岐を1つ足したが、性能は測っていない |
| 性能効率性・計算量の記載 | 公開29宣言のどのコメントにも計算量の記載が無い。実装上、`removeAll()`とdeinitは全slotを走査し、subscriptはoffset計算と`precondition`だけ | Audit OPT-024（計算量は29件すべて「なし」）、L36〜L56、L163〜L170 | 計算量を契約として約束するかは決まっていない | 実装から読める計算量は事実であり、公開契約ではない |
| 性能効率性・資源効率性 | 所有型は`hasPayload: UnsafeMutablePointer<Bool>`と`payload: UnsafeMutablePointer<Element>`の2領域をcapacity分確保する。`removeAll()`はcapacityを保持する | L23〜L25、L123〜L127、L49〜L56 | 確保量の測定、`Element`のlayoutによる差は確かめていない。`removeAll()`のcapacity保持はコメントに無い（Audit OPT-024） | storage再設計は`ARRAY-001`（凍結）の範囲 |
| 性能効率性・最適化属性 | 公開APIは`@inlinable`、storageは`@usableFromInline`、subscriptのaccessorは`@inline(__always)` | L22〜L28、L67、L76など | 属性ごとの効果は測っていない | 属性の意図は導入時期で判断する運用がある（2026-09-19より前はユーザーの意図） |
| 互換性・共存性 | `AcCollections`が`@_exported import OptionalArrayModule`で再公開する。`AcCollectionsTests`の`test_importAcCollections_exposesOptionalArray`が、facade経由で使えることを確かめている。同じfacadeでBareArray・RedBlackTree・Permutationと同時にimportされ、package全体がbuildできる | `Sources/AcCollections/AcCollections.swift:3`、`Tests/AcCollectionsTests/AcCollectionsTests.swift:77` | 外部package（swift-algorithms、swift-collections等）と同時importした際の名前衝突は確かめていない | 互換mode（`COMPATIBLE_ATCODER_2025`）の分岐はOptionalArrayに無い（OPT-033実施結果） |
| 互換性・相互運用性 | 公開型は標準protocol（`Sequence`、`Collection`など）に適合しない。`indices`は`Range<Int>`を返す | Audit OPT-015（公開適合は`Sendable`の4件だけ） | — | 標準protocolへの適合を求めるかは契約・文書側の判断 |
| 柔軟性・適応性（platform・toolchain） | `swift-tools-version: 6.2`、`platforms: [.macOS(.v15)]`。CIはubuntu-24.04でdebug / release / Address Sanitizerを`swift test`で実行する。sourceは`~Copyable`、`borrowing`、`unsafe`式を使う | `Package.swift:1`、`Package.swift:119-121`、`.github/workflows/ci.yml` | macOS以外のApple platform、Windows、Swift 6.2未満では確かめていない。CIの実行結果はこの調査で見ていない | OptionalArrayModuleのtargetは`swiftSettings`を持たず、package共通の`_settings`（`_O_UNCHECKED`の`-Ounchecked`を含む）も`.strictMemorySafety()`も適用されない（`Package.swift:290-291`）。test targetは`_settings`を使う |
| 柔軟性・設置性／置換性 | 公開productは`AcCollections`だけ。sourceは1 file（521行）で`import`を持たず、冒頭に「コピペで提出に使っていただいて構いません。提出の際のライセンス記載は不要です。」とある。Audit OPT-020では、このfileを一時directoryへcopyして単独でbuild・実行できた | `Package.swift:122`、L12〜L13、Audit OPT-020 | 現行HEADでの単独copy buildは、本日は再実行していない | copy & paste提出はSwiftPMの依存とは別の配布経路で、ライセンス表記は利用者向けの記載 |
| 柔軟性・拡張性（scalability） | 次元積が`Int`で表せる範囲を上限とし、超える入力は停止する。zero dimensionは有効な空配列 | L131〜L133ほか、`OptionalArray_1_InitializationTests.swift`、`OptionalArray_99_DeathTests.swift`の`productOverflow_traps_*` | 大きなcapacityでの確保失敗時の挙動は、負のcapacityの確保失敗（Audit OPT-022の旧挙動）以外に記録が無い | 確保失敗は`allocate`の挙動で、OptionalArrayの契約ではない |

停止事項: なし。

### 3.3 インタラクション能力・セキュリティ・保守性・利用時の品質

担当: Claude。APIの自己記述性、誤用時の挙動、strict memory safety、unsafe境界、View寿命、source構成、
Test as Specification、EDPC利用例を調べ、3.1と同じ列の表にする。コメントドック不足と仕様不足を区別し、
文書形式や改善の採否は決めない。

#### 3.3 Claude証拠（OPT-041、2026-10-08）

2026-10-08 / Claude Opus 5.5（`claude-opus-5-5`）。HEAD `ad82f4e7`。略記は3.1と同じ。
「コメントドック不足」は公開宣言に説明の文が無いこと、「仕様不足」は契約を固定するtestが無いことを指す。該当する行では、どちらかを明記して書き分ける。

| 特性・副特性 | 確認できる事実 | 根拠 | 未検証範囲 | 評価時に区別すべき前提 |
| --- | --- | --- | --- | --- |
| インタラクション能力・自己記述性 | コメントドックがあるのは29件中10件（1D型、1D `removeAll()`、1D subscript、2D〜4D型の型コメント、View 3型、1DView subscript）。19件は無い。境界を明示するのは1D・1DViewのsubscriptだけ、計算量は0件。2D〜4Dの型コメントは1Dの冒頭と同じ「メモ化用配列」の3文だけで（例: L116〜L119）、次元の意味や添字順を述べない | Audit OPT-024 | — | コメントドック不足: 上記。仕様不足とは別。添字順（外→内）とinitの引数順（内→外）が逆であることはAudit OPT-020の事実で、コメントには無い |
| インタラクション能力・利用者の誤り防止 | 所有型は`~Copyable`で、暗黙のcopyはcompile errorになる。次元・添字の契約違反は`precondition`で停止する（`-O`まで）。Viewは親より長く保持してはいけないと型コメントにあるが、型システムでは拘束されない（Viewは`Copyable`なstruct） | L21、L363〜L368、Audit引き渡し判定節 | Viewを親より長く保持した場合の挙動はtestが無く、実行もしていない（未定義の可能性があるため） | 仕様不足: Viewの寿命は契約として文書にあるが、固定するtestは無い（固定できるかも未確認） |
| インタラクション能力・学習性 | 利用例はEDPC-J / EDPC-Lの2 fileで、`nonisolated(unsafe) var`の`~Copyable`値をローカル関数からcaptureする形を含む。利用者向け文書は未作成 | Audit OPT-023 | 利用例は実行されない | 利用者向け文書の形式は未決定（Registryの「次の判断は今回の作業taskへ含めない」） |
| セキュリティ・完全性（メモリ安全性） | storageは`UnsafeMutablePointer`の生ポインタ。`.strictMemorySafety()`はOptionalArrayModuleに未適用で、一時適用時の残り診断は21箇所（unsafe型をstorageに持つ7、Viewのpointer initializerでの代入6、strict時だけunsafeになる`allocate` 8）。局所的なポインタ操作はscoped `unsafe`で明示済み | `Maintanance/StrictMemorySafetyReadiness.md` §11、`Package.swift:290-291` | strict恒久適用時の診断数は、§11のバッチ4（2026-10-03）以降は数え直していない。OPT-033・034で変えたinitializerと4D subscriptが診断数を変えたかは未確認 | 恒久適用には公開7型への`@unsafe`伝播か、生ポインタstorageの隔離設計が要る（§11）。storage再設計は`ARRAY-001`（凍結） |
| セキュリティ・完全性（範囲外access） | 全添字経路は`precondition`で検査する。`-Ounchecked`では検査が消え、範囲外の添字がそのまま通る（一時実測）。不正次元・次元積overflowの検査も`precondition`なので、`-Ounchecked`では確保量と論理次元が食い違い得る | Audit OPT-018、Audit OPT-022、L131〜L133ほか | OPT-033後の`-Ounchecked`は実行していない。範囲外accessそのものは実行していない（未定義動作のため） | Codexが`OPT-008`の境界契約・安全性論点として受領済み。望ましい方針は未決定 |
| セキュリティ・完全性（並行利用） | 所有4型は`Element: Sendable`のとき`@unchecked Sendable`。保持する`UnsafeMutablePointer`が`Sendable`でないため、検査付きの適合は書けない。View 3型は適合しない | L100 / L188 / L270 / L359、Audit OPT-021 | compile testは1Dだけで、並行実行のtestは無い（`OptionalArray_0_PublicSurfaceTests.swift`）。導入理由と許される並行利用の範囲（移送だけか共有もか）は記録が無い | Audit引き渡し判定節:「並行共有を許す契約ではない」 |
| セキュリティ・検知 | CIにAddress Sanitizer jobがあり、`swift test -c debug --sanitize address`でOptionalArrayのtestも走る | `.github/workflows/ci.yml`（Address Sanitizer job） | このjobの実行結果は、この調査では見ていない | ASanが見るのはtestが通る経路だけ |
| 保守性・モジュール性／再利用性 | source 1 file 521行に所有4型とView 3型。所有4型の`deinit`と`removeAll()`はほぼ同形を各型に持つ。依存moduleは無い | `OptinalArray.swift`、L36〜L56とL142〜L160など | — | 共通化はstorage再設計（`ARRAY-001`、凍結）と関わる |
| 保守性・解析性／修正性 | 修正履歴に、3DView面stride（`89a93f9d`）、次元検査の追加（`85febb0a`）、4D zero-volume subscript（`244c6083`）がある。いずれも先に失敗するtestを確認してから直した記録がある | `git log -- Sources/OptionalArrayModule/OptinalArray.swift`、Audit OPT-033・034実施結果 | — | — |
| 保守性・試験性（Test as Specification） | 番号付き仕様test 7 file（35件）とDeath Test 1 file（21件）に、公開契約別に一度ずつ配置済み。testは`OptionalArrayModule`だけに依存し、test間で共有する状態は無い | `Tests/OptionalArrayModuleTests/OptionalArray_0_`〜`_6_`、`_99_`、Audit OPT-035、OPT-036・037実施結果 | 仕様不足: 所有型strideのalias検出、境界の一部、参照型寿命の一部（3.1参照）。Sendableのcompile testは1Dだけ | 通常testはXCTest、Death TestはSwift Testing。frameworkの移行はTest as Specification整理の完了条件に含めない（Audit OPT-012分割） |
| 利用時の品質（競技プログラミングでのメモ化） | EDPC-J（期待値DP、310³）とEDPC-L（区間DP、3001²）が、実際の提出形に近い使い方をcompileする | Audit OPT-023 | 実行時間・メモリ使用量・正答は確かめていない。利用者の記録（提出結果など）は見つからない | 利用時の品質は主な利用文脈と既存利用例の範囲だけを扱う（本書§1） |

停止事項: 新しいdefect、ユーザー判断、公開契約変更が必要な事項は見つからなかった。strict診断数がOPT-033・034で変わったかは、Package設定を一時変更しないと確かめられないため実施していない（本書§2の変更禁止に従った）。

## 4. Codex評価・初版判定

3.1〜3.3の証拠を受け入れ、競技プログラミング用の低レベル公開部品という決定済みの位置づけに対して
初版を判定する。`部分`は直ちに公開を妨げる意味ではなく、確認済みの品質と残る不足が併存することを示す。

| 品質特性 | 判定 | 初版の根拠 |
| --- | --- | --- |
| 機能適合性 | 満たす | 公開29宣言の契約が棚卸しされ、主要な成功経路、非対称次元、zero dimension、参照型寿命を仕様testで固定している。メモ化用途の利用形状もcompileする |
| 性能効率性 | 未評価 | 固定次元のoffset計算とcapacity保持という実装事実はあるが、benchmark、時間、確保量の測定根拠が無い |
| 互換性 | 部分 | `AcCollections`経由の再公開とpackage内の共存はtest済み。外部packageとの名前衝突、標準collection protocolとの相互運用は未確認または未提供 |
| インタラクション能力 | 部分 | 型名と一部コメントから用途は読めるが、公開29宣言中19件にコメントドックがなく、次元・添字順、境界、計算量の説明が不足する |
| 信頼性 | 部分 | Debug／Releaseの仕様testとDeath Test、参照型寿命testがある。一方、停止理由を区別せず、境界・stride・寿命の一部に直接testが無い |
| セキュリティ | 部分 | 添字と次元は通常構成で事前条件検査され、CIにASanがある。生ポインタstorage、型で拘束されないView寿命、未検証の`@unchecked Sendable`範囲、`-Ounchecked`で消える検査が残る |
| 保守性 | 部分 | 単一fileで依存がなく、番号付きTest as Specificationと修正履歴が追跡可能。所有4型の重複実装とstrict memory safety未適用は将来変更の負担となる |
| 柔軟性 | 部分 | SwiftPM再公開と単一file利用の二経路があり、zero dimensionを扱える。確認platform・toolchainが限られ、巨大capacityや他環境の根拠は無い |
| 安全性 | 対象外 | 人命・財産・環境への危害を直接制御する部品ではない。メモリ安全性はセキュリティとして評価した |

利用時の品質は、EDPC-J／Lが利用形状をcompileするところまでしか確認できないため`未評価`とする。
正答、実行時間、メモリ使用量、実提出の記録は初版の根拠に含めない。

## 5. 引き渡し事項

### 5.1 利用者向け文書作業で埋める不足

- 各型の用途、所有／非所有、Viewを親より長く保持できないことを説明する。
- initializerの次元順とsubscriptの添字順、各軸の意味、zero dimension、不正次元と範囲外添字の事前条件を説明する。
- `removeAll()`がcapacityを保持すること、主要操作の計算量、標準`Collection`ではないことを説明する。
- `@unchecked Sendable`は並行共有の保証ではないことと、`-Ounchecked`では事前条件検査に依存できないことを明示する。
- EDPC利用例を利用者向けに採用する場合は、compile対象に留まる現状と、正答例として検証した例を区別する。

### 5.2 1.0準備で再評価する不足

- 性能効率性を1.0判断に使うなら、代表的な次元・capacity・要素型と比較対象を先に決めて測定する。
- 所有2D〜4Dのstride alias、未検証の境界、参照型寿命、所有4型すべての`Sendable`について、必要性を判定してから仕様testを補う。
- strict memory safetyの現行診断を再計測し、公開`@unsafe`伝播とstorage隔離のどちらを1.0へ採るかは既存の凍結taskを再開する場合に判断する。
- View寿命と`@unchecked Sendable`の許容範囲を公開契約として説明できる状態にし、`-Ounchecked`を主要構成とする場合は事前条件実装を再判断する。
- 利用者向け文書完成後、この初版を再評価し、`部分`または`未評価`のうち1.0前に解消する項目だけを独立taskへ分離する。

## 6. 初版完成判定

9つの製品品質特性について評価語、根拠、既知の不足を記録し、利用者向け文書作業と1.0準備への境界を
分離したため、初版は完成と判定する。この判定はOptionalArrayの1.0採用判定ではなく、文書作業後の再評価を
省略するものでもない。
