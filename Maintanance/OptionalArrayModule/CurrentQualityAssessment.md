# OptionalArrayModule Current Quality Assessment

## 文書の役割

この文書は、OptionalArrayModuleの0.6.0時点の現行品質評価を記録する。
上位品質要求は`Maintanance/QUALITY_REQUIREMENTS.md`、モジュールへの適用と証拠境界は
`Sources/OptionalArrayModule/Documentation/Quality-Profile.md`を正本とする。
体系監査と過去の判断は`OptionalArrayAudit.md`を参照するが、旧評価の判定は継承しない。

## Task

- 種別: `DISCOVERY`
- 担当: Codex
- 現在の中間ゴールへの近さ: `DIRECT`
- 評価日: 2026-10-11

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

現行Quality Profileは、所有4型、非所有View 3型、番号付きTest as Specification、性能証拠、
`Sendable`、strict memory safety、`-Ounchecked`の境界を扱う。2026-10-13、連鎖subscriptと
非所有View 3型はdeprecatedとなり、座標access methodが現行経路になった。

## 現行評価

| 上位要求 | 品質主張 | 評価 | 現在の証拠 | 未確認範囲・残余リスク |
| --- | --- | --- | --- | --- |
| QR-01 正確性 | 初期化、nil状態、次元、offset、subscript、View、writeback、`removeAll()`、破棄が公開契約どおり動作する | 確認済み | Debug・Releaseで通常test 35件とDeath Test 26件が成功。非対称次元、zero dimension、積overflow、別storage View代入、参照要素寿命を含む | 有限な型、寸法、操作列によるVerificationであり、任意入力の証明ではない |
| QR-02 性能効率性 | presence mapとpayloadの連続storage、O(1) access、線形初期化・破棄という実装特性が公開説明と一致する | 確認済み | sourceとdocumentation commentを照合。要素accessとView生成は定数回のoffset計算、初期化・`removeAll()`・破棄はcapacityに比例する | 実装構造上の計算量であり、実行時間、allocation cost、最適化結果を証明しない |
| QR-02 性能効率性 | 利用目的に対する外部性能が十分である | 未検証 | 2D・3Dのcold / warm memoization benchmarkはCIへ登録済み | C++ nested vector番兵版との外部比較結果と性能比の受入水準は未確定 |
| QR-03 安全性 | storage確保・要素寿命・範囲・次元・writeback拒否が検証した経路で成立する | 確認済み | Debug・Releaseに加え、ASanで通常test 35件とDeath Test 26件が成功し、OptionalArray由来のSanitizer failureはなかった | ASanと有限のtest経路で観測できないunsafe操作の正しさまでは証明しない |
| QR-03 安全性 | deprecated非所有Viewを所有元より長く保持できない | 部分確認 | View 3型は`~Escapable`で、所有元とView間の寿命依存を宣言している | compiler escape fixtureによる独立した反証確認はない。deprecated互換面であり、現行座標access APIの採用条件にはしない |
| QR-03 安全性 | strict memory safety下で公開APIとunsafe境界が成立する | 確認済み | 所有4型とView 3型を`@safe`に分類し、低レベル操作をscoped `unsafe`へ限定。targetへ`.strictMemorySafety()`を恒久適用し、単独typecheck警告0・エラー0、Build for Testing成功、全65 test成功 | strict設定はunsafe実装自体の正しさを証明せず、境界の明示と未注釈操作の検出を提供する |
| QR-03 安全性 | `@unchecked Sendable`が許す移送・共有の範囲が妥当である | 未検証 | 所有4型に条件付き適合がある。compile testは1Dのみ | 2D〜4Dの表面確認、移送後の所有、並行共有・data raceの意味的Validationは未実施 |
| QR-03 安全性 | `-Ounchecked`で省略される事前条件との境界が受入可能である | 未検証 | 公開コメントは検査省略可能性を明示する | `-Ounchecked`構成の実行、範囲・次元・writeback違反時の扱いは評価していない |
| QR-04 理解可能性 | nil状態、所有と非所有、軸順、`removeAll()`、失敗条件を公開文書から確認できる | 確認済み | 公開29宣言のdocumentation commentを監査済みで、DocCをwarnings-as-errors付きで生成できた | 文書と実装のVerificationであり、一般利用者が誤解なく使えることのValidationではない |
| QR-05 利用可能性 | SwiftPMと`AcCollections`再公開経路で利用できる | 確認済み | OptionalArrayModule build、facade再公開test 1件、DocC生成が現行macOS環境で成功 | 他platform、外部packageとの共存、実利用は未確認 |
| QR-05 利用可能性 | 競技プログラミングで実用できる | 未検証 | EDPC-J・EDPC-Lはtest targetのcompile evidenceであり、単一file利用許諾もsourceにある | 正答、実提出、実行時間、メモリ使用量は確認していない |
| QR-06 持続可能性 | 変更後に公開面、状態、寿命、次元、停止契約を再確認できる | 確認済み | 番号付きTest as Specification 8群、Debug・Release・ASanのCI job、および2D・3D memoization accessの回帰workloadがある | 現行commitのremote CI成功は未確認。CIのDocC対象にOptionalArrayは含まれない |

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
- Xcodeで`OptionalArrayModuleTests`の9 suiteを実行: 65件成功、失敗0件。deprecated View互換testと
  Death Testを含む。
- BenchmarkのRelease buildに成功。2D・3Dのcold / warm memoization checksum 4件をsize 1・3・16で
  3反復し、全件のchecksum検証に成功。
- `Benchmarks/Libraries/CI.json`は30 task・60 size・最大64kを70.4秒で完走。OptionalArray 4件を
  通常CI libraryの選択対象として実行した。

SwiftPM user cacheが書込み不可である環境警告と、ASan build時にOptionalArray testの`var` 1件、
RedBlackTree testの未使用値2件のwarningが出た。製品OptionalArrayModuleの通常buildにはwarningがない。

## 多次元access性能測定設計

OptionalArrayの競技用途であるmemoizationを表すため、2Dと3Dのそれぞれで次の2状態を測定する。

- cold access: 未設定slotを読み、未設定なら線形indexと同じ値を保存し、保存値をchecksumへ加える。
- warm access: 同じ値で事前に全slotを設定し、設定済み値の読み取りだけをchecksumへ加える。

shapeはBareArray測定と同じ総要素数の素因数を各軸へ均衡に割り当て、積が入力sizeと完全に
一致する2D・3D shapeを用いる。走査は最内軸から連続する順序とし、期待checksumは
`size * (size - 1) / 2`とする。

配列の確保、shape計算、warm状態の事前設定は計測外に置く。計測内には連鎖subscriptによる
presence確認、cold時の値保存、値取得、checksum更新だけを含める。checksumは計測後に
`blackHole`と`precondition`へ渡し、最適化による消去と誤った走査を検出する。

CIにはSwift版の4 workloadだけを通常libraryへ登録する。後続のC++外部assessmentでは、
nested `vector<Int>`を同じshapeで確保し、未設定を表す番兵値をpresence判定に用いて、
同じcold / warm操作、走査順、checksumに対応させる。C++ workloadは通常CIには含めない。

## 現行座標access Test as Specification監査（2026-10-13）

deprecatedとなった連鎖subscript・非所有Viewの互換testと、現行`element`／`setElement`の仕様証拠を
分離して確認した。direct methodの既存testは1D〜4Dで各1座標のnil→value→nilと近傍1点を確認するが、
次は未検証だった。

- 非対称shapeの全座標を通した軸順・stride。
- 選択座標だけが変更され、各軸の近傍が変化しないこと。
- direct `setElement`による参照要素の上書きとnil遷移で、旧要素がちょうど一度破棄されること。
- 1D〜4Dの各軸について、`element`と`setElement`が負値と上限値をSwift trapで拒否すること。

これらは既存の次元、座標順、範囲、要素所有契約から直接導け、新しい製品判断を要しない。
deprecated Viewの寿命・writeback仕様は互換testへ残し、現行座標accessの受入証拠には数えない。

上記不足を現行API専用のtestへ実装した。非対称shapeの全座標を1D〜4Dで読み書きして軸順とstrideを固定し、
各軸の近傍が未設定のままであること、参照要素の置換とnil化が各値をexactly onceで破棄することを確認する。
Death Testは1D〜4Dの全軸について、負値と上限値をread・writeの双方で与え、Darwinでは`SIGTRAP`、
Linuxでは`SIGILL`というSwift preconditionのsignalまで固定した。2026-10-13にBuild for Testingが成功し、
追加した通常test 3件とDeath Test 8件を含むOptionalArray全76件が成功した。

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

## 判断の整理

- 1D所有型名と次元名体系は、0.6.0到達範囲判断の前に残る製品上の判断である。ただし現行名での
  Verificationを妨げないため、今回の品質評価の前提にはしない。
- 旧31診断という評価は現行sourceに対して失効した。再取得した40件は、所有型分類4件、allocation
  境界8件、deprecated View経路28件へ分離でき、製品判断を追加せず警告0件へ整理できた。
- Viewはdeprecated互換面として残す。寿命設計を現行APIとして磨かず、削除まで既存挙動とstrict境界を
  維持する。
- 性能、一般利用、競技利用、`Sendable`、`-Ounchecked`は証拠不足であり、成功とも失敗とも判断しない。
- 多次元accessの測定条件は、OptionalArrayの既存用途とBareArrayで確定済みのshape・計測境界から
  導ける。新しい製品仕様や性能比の受入水準を決めないため、設計時のユーザー判断は発生しない。

## 後続task候補

| 種別 | 近さ | 内容 | 境界 |
| --- | --- | --- | --- |
| 既存`DECISION` | `DIRECT` | 1D所有型名 | 品質評価とは独立した公開名称だけを扱う |
| 既存`DECISION` | `DIRECT` | 次元名体系 | 品質評価とは独立した公開名称だけを扱う |
| 既存`DISCOVERY` | `LATER` | 1.0前の品質再評価 | ユーザードキュメント完了後、性能と利用Validationを含む1.0不足を再評価する |

## 結論

0.6.0時点の現行品質アセスメントは完了した。正確性、検証したメモリ経路、公開説明、package利用経路、
回帰構造とstrict memory safetyには現行証拠がある。一方、`Sendable`、`-Ounchecked`、外部性能、
一般利用・競技利用のValidationは未検証である。deprecated Viewの独立したescape fixtureは無いが、
現行座標access APIの採用条件にはしない。
