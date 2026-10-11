# OptionalArrayModule Current Quality Assessment

## 文書の役割

この文書は、OptionalArrayModuleの0.6.0時点の現行品質評価を記録する。
上位品質要求は`Maintanance/User/QUALITY_REQUIREMENTS.md`、モジュールへの適用と証拠境界は
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
View寿命、`Sendable`、strict memory safety、`-Ounchecked`の境界を現行実装と一致して扱っている。
現在評価を旧判定から分離する規定も有効であり、今回の評価前にリフレッシュする必要はない。

## 現行評価

| 上位要求 | 品質主張 | 評価 | 現在の証拠 | 未確認範囲・残余リスク |
| --- | --- | --- | --- | --- |
| QR-01 正確性 | 初期化、nil状態、次元、offset、subscript、View、writeback、`removeAll()`、破棄が公開契約どおり動作する | 確認済み | Debug・Releaseで通常test 35件とDeath Test 26件が成功。非対称次元、zero dimension、積overflow、別storage View代入、参照要素寿命を含む | 有限な型、寸法、操作列によるVerificationであり、任意入力の証明ではない |
| QR-02 性能効率性 | presence mapとpayloadの連続storage、O(1) access、線形初期化・破棄という実装特性が公開説明と一致する | 確認済み | sourceとdocumentation commentを照合。要素accessとView生成は定数回のoffset計算、初期化・`removeAll()`・破棄はcapacityに比例する | 実装構造上の計算量であり、実行時間、allocation cost、最適化結果を証明しない |
| QR-02 性能効率性 | 利用目的に対する外部性能が十分である | 未検証 | OptionalArray固有のbenchmark登録と比較結果はない | 比較対象、scenario、入力形状、判定水準が未確定 |
| QR-03 安全性 | storage確保・要素寿命・範囲・次元・writeback拒否が検証した経路で成立する | 確認済み | Debug・Releaseに加え、ASanで通常test 35件とDeath Test 26件が成功し、OptionalArray由来のSanitizer failureはなかった | ASanと有限のtest経路で観測できないunsafe操作の正しさまでは証明しない |
| QR-03 安全性 | 非所有Viewを所有元より長く保持できない | 未達 | 公開文書は親の生存中だけ使う責任を明示するが、View 3型は通常の`Escapable`な値で、生ポインタを保持する | 現行型システムはdangling Viewを拒否しない。Swift 6.4 Lifetimesの適用可能性は未評価 |
| QR-03 安全性 | strict memory safety下で公開APIとunsafe境界が成立する | 未達 | OptionalArrayModule targetには`.strictMemorySafety()`がない。単独typecheckは成功するが、公開7型のunsafe storage 7件を含む31診断を報告した | 公開型分類、View寿命との依存、scoped `unsafe`不足を整理する前に採否を判断できない |
| QR-03 安全性 | `@unchecked Sendable`が許す移送・共有の範囲が妥当である | 未検証 | 所有4型に条件付き適合がある。compile testは1Dのみ | 2D〜4Dの表面確認、移送後の所有、並行共有・data raceの意味的Validationは未実施 |
| QR-03 安全性 | `-Ounchecked`で省略される事前条件との境界が受入可能である | 未検証 | 公開コメントは検査省略可能性を明示する | `-Ounchecked`構成の実行、範囲・次元・writeback違反時の扱いは評価していない |
| QR-04 理解可能性 | nil状態、所有と非所有、軸順、`removeAll()`、失敗条件を公開文書から確認できる | 確認済み | 公開29宣言のdocumentation commentを監査済みで、DocCをwarnings-as-errors付きで生成できた | 文書と実装のVerificationであり、一般利用者が誤解なく使えることのValidationではない |
| QR-05 利用可能性 | SwiftPMと`AcCollections`再公開経路で利用できる | 確認済み | OptionalArrayModule build、facade再公開test 1件、DocC生成が現行macOS環境で成功 | 他platform、外部packageとの共存、実利用は未確認 |
| QR-05 利用可能性 | 競技プログラミングで実用できる | 未検証 | EDPC-J・EDPC-Lはtest targetのcompile evidenceであり、単一file利用許諾もsourceにある | 正答、実提出、実行時間、メモリ使用量は確認していない |
| QR-06 持続可能性 | 変更後に公開面、状態、寿命、次元、停止契約を再確認できる | 確認済み | 番号付きTest as Specification 8群とDebug・Release・ASanのCI jobがある | 現行commitのremote CI成功は未確認。CIのDocC対象とperformance workloadにOptionalArrayは含まれない |

## 実行記録

- `swift test --disable-sandbox --filter OptionalArrayModuleTests`: 通常test 35件、Death Test 26件成功。
- `swift test -c release --disable-sandbox --filter OptionalArrayModuleTests`: 通常test 35件、Death Test 26件成功。
- `swift test --disable-sandbox --sanitize address --filter 'OptionalArray_'`: 通常test 35件、Death Test 26件成功。
- `AcCollectionsTests.test_importAcCollections_exposesOptionalArray`: 1件成功。
- `swift package --disable-sandbox generate-documentation --target OptionalArrayModule --warnings-as-errors`: 成功。
- `swift build --disable-sandbox --target OptionalArrayModule`: 成功。
- `swiftc -typecheck -swift-version 6 -strict-memory-safety`による単独typecheck: error 0、strict memory safety診断31件。

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

## 判断の整理

- 1D所有型名と次元名体系は、0.6.0到達範囲判断の前に残る製品上の判断である。ただし現行名での
  Verificationを妨げないため、今回の品質評価の前提にはしない。
- strict memory safetyの採否を直ちにユーザー判断へ渡さない。31診断は、View寿命、公開型分類、
  scoped `unsafe`の依存が未整理なために判断が必要に見えている可能性がある。
- View寿命の既存契約は「親より長く保持しない」であり、その契約を変える判断は現時点で見つかって
  いない。まずSwift 6.4 Lifetimesで既存契約を型へ移せるかを調べる。
- 性能、一般利用、競技利用、`Sendable`、`-Ounchecked`は証拠不足であり、成功とも失敗とも判断しない。
- 多次元accessの測定条件は、OptionalArrayの既存用途とBareArrayで確定済みのshape・計測境界から
  導ける。新しい製品仕様や性能比の受入水準を決めないため、設計時のユーザー判断は発生しない。

## 後続task候補

| 種別 | 近さ | 内容 | 境界 |
| --- | --- | --- | --- |
| `DISCOVERY` | `DIRECT` | View寿命・公開安全性分類・strict memory safetyの依存分解 | 既存契約とSwift 6.4の機能から判断不要で閉じる範囲を特定し、本質的判断が残る場合だけ分離する |
| 既存`DECISION` | `DIRECT` | 1D所有型名 | 品質評価とは独立した公開名称だけを扱う |
| 既存`DECISION` | `DIRECT` | 次元名体系 | 品質評価とは独立した公開名称だけを扱う |
| 既存`DISCOVERY` | `LATER` | 1.0前の品質再評価 | ユーザードキュメント完了後、性能と利用Validationを含む1.0不足を再評価する |

## 結論

0.6.0時点の現行品質アセスメントは完了した。正確性、検証したメモリ経路、公開説明、package利用経路、
回帰構造には現行証拠がある。一方、View寿命とstrict memory safetyは未達、`Sendable`、`-Ounchecked`、
外部性能、一般利用・競技利用のValidationは未検証である。

この評価から新しいユーザー判断は発生しない。次の必須作業は、View寿命・公開型分類・strict memory
safetyをDiscoveryとして分解し、偶有的判断を除去することである。
