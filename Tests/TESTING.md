# テストメンテナンス・ダッシュボード

現在情報だけを保持する。作業規則は `Tests/CLAUDE.md`、CodexからClaudeへの依頼は
`Maintanance/CLAUDE_TASK.md`、2026-10-03以前の詳細は `Tests/Archived/TESTING_REFERENCE.md` にある。
参照資料は必要な箇所だけ検索し、通常は通読しない。

## 目的

- テストを継続的に整理し、公開APIの仕様不足や実装不具合を発見する。
- テスト成功だけで完了とせず、公開API一覧と実装に対する不足を確認する。

## 優先事項

赤黒木の完成判断を優先する。C++挙動比較はSet/MultiSet/Dictionary/MultiMapの
4組へ展開済みで、`CppBehaviorReferenceTests` 35件の比較が成功している。
挙動比較ターゲットはルートパッケージへ置き、性能測定用の`CppBenchmarks`は
`Benchmarks`へ残す。独立した公開範囲の縮小は区切り済みである。現在の確認地点は、
Swift Collectionsの`ContainersPreview`が安定した時点で行うIndex契約の最終判断である。

## 現在地

- RedBlackTree 4型の空コレクション用シングルトン(`_emptyTreeStorage`、型消去済み
  capacity 0)の生存条件を4型すべてで確認し、
  `RedBlackTreeInternal_EmptySingletonTests.swift`へ記録済み。通常初期化・
  `minimumCapacity: 0`・空コレクションのコピーはシングルトンを維持し、
  `reserveCapacity`(0含む)・正のminimumCapacity指定・最初の挿入でdetachする。
  最後の要素削除後もシングルトンへは戻らず確保済みバッファを保持し、
  `removeAll(keepingCapacity: false)`のみシングルトンへ復帰する。通常/
  `COMPATIBLE_ATCODER_2025`の両方で同一挙動。production codeの変更なし。
- RedBlackTree 4型の `_98_FuzzTests.swift`: 参照モデル比較と操作ごとの
  `___tree_invariant_for_fuzz()` チェックを同一の操作列・状態に対して行うよう
  統合済み。MultiSet/MultiMapは「選択キーのみ」の部分比較だった箇所を全要素
  比較に強化した。production codeの変更なし、不具合は未検出。
- 空コレクションへの`removeFirst()` / `removeLast()`は、4コンテナと3種の共有Viewで
  Death Testを整備済み。Debugと通常Releaseでは停止し、Release + `_O_UNCHECKED`では
  標準ライブラリ同様に`preconditionFailure`が保証されない。これは採用済みの実行時検査
  方針であり、CIは`_O_UNCHECKED`を使用しない。Viewの8件を追加し、既存分と合わせた
  16件で構成差を確認した。互換モードのテストビルドも成功している。
- `index(inserting:)`と`erase(exactly:)`は4コンテナへ横展開済み。4つのInsertion suite
  63件、フルDebug、互換モードのテストビルドが成功した。Setの空`erase(exactly:)`で
  発見した不要なCoWも修正済み。性能jobはpush後のCIへ委ねる。
- Bound-rangeの`erase` / `erase(_:where:)`は、4型で逆順範囲・Multi型の同一キー逆順範囲・
  predicate非呼出しを仕様化した。4つのBoundExpression suite 81件、フルDebug、互換モードの
  テストビルドが成功した。空コレクションでの不要なCoWは8経路を修正済み。Index-range版の
  空guardはIndex契約を変え得るため未変更である。
- cross-tree Index契約の監査で不足していたF3/F4を4型へ、F2をMultiMapへ追加した。
  detached前提を確認する内部テストも4型へ展開済み。追加分、フルDebug、互換モードの
  テストビルドは成功した。`ALLOW_CROSS_TREE_INDEX`なしでは予測どおり3件が失敗し、
  CROSS=OFFは実質deprecatedとして扱う。標準構成のテスト不足ではない。

- OptionalArrayModule: Release実行、Death Test、参照型寿命、公開API化漏れを対応済み。
  strict memory safetyの4バッチで所有型の破棄・変更・初期化とView境界を整理し、
  一意な診断を82→62→44→40→21へ削減。参照型寿命は2D〜4Dの破棄と3D/4Dの
  `removeAll()`後の再利用までテスト済み。残りは公開7型のunsafe storage・Viewでの
  storage代入・8つの`allocate`。
  公開APIへunsafeを伝播させずstorageを隔離できる設計までstrict恒久適用を保留する。
- BareArrayModule: Debug/Release、境界Death Test、参照型寿命をレビュー済み。
  3D cloneのcapacity不足による参照解放漏れを修正し、1D〜4D cloneの参照所有を
  テスト済み。strict memory safetyの第1バッチとして
  4つの所有型の`deinit`、初期化済み要素への書き込み、cloneをscoped `unsafe`化し、
  所有型・View型のpointer initializerと添字境界も整理して、一意な診断を
  約64→54→38→28→22へ削減した。残りは公開7型を`@unsafe`にするAPI判断とallocate。
  公開API全体へunsafeを伝播させる変更は採らず、storage再設計までstrict恒久適用を保留する。

### OptionalArray体系監査と管理方式の検証

詳細な契約表、test対応、履歴根拠、判断候補は
`Maintanance/OptionalArrayModule/OptionalArrayAudit.md`を正本とする。

現在の到達点は、OptionalArrayをCodexのユーザードキュメント作業フェーズへ渡せる状態にすることである。
Codexが作業設計、調査範囲の閉鎖、網羅性確認、成果物の受入れ、完了判定を担う。Claudeへ作業を委任する
場合も、対象・確認資料・成果物形式・停止条件をCodexが指定し、その提出だけで親taskを完了扱いにしない。
新しい判断点はagentが補わず、一判断ごとの`DECISION`候補として分離する。

この管理方式は次の順で検証する。

1. BareArrayの親・子・後続性能taskと`ARRAY-001`を凍結し、途中成果を保持する。
2. OptionalArrayの体系監査・名称再検討をCodex管理で再開し、ユーザードキュメント作業へ渡す。
3. 完了後、実際に有効だった作業設計・責任境界・受入基準を抽出する。
4. Claude向け委任規則を正本へ明文化する必要があるかを別taskで判断し、必要な場合だけ反映する。
5. 検証済みの管理方式を踏まえ、BareArray監査を再開するかを別taskで判断する。

BareArrayについて既に登録した公開7型の契約棚卸し、位置づけ、命名、Test as Specification、性能の論点は
削除しない。再開判断までは追加調査・判断・整理を行わず、コメントドック全件整備も開始しない。

#### BareArray監査の再開判断（2026-10-09）

ユーザー判断により、OptionalArrayで検証した管理方式を用いてBareArray監査を再開する。
現在の中間ゴールは、BareArrayをCodexのユーザードキュメント作業フェーズへ渡せる状態にすることとする。

- 親監査`BARE-001`と公開7型の契約棚卸し`BARE-002`を再開する。
- `BARE-002`は既存のsafety・test証拠を入力に、境界・寿命・破棄の契約を履歴、OptionalArrayとの対応に
  照らして閉じる。完成済みの公開宣言ledgerはまだなく、類似だけを同一契約の根拠にしない。
- 位置づけ`BARE-003`と命名`BARE-004`は、棚卸しで未決定と判明した場合だけ一判断ずつユーザーへ返す。
- Test as Specification整理`BARE-005`は`BARE-002`の受入後に進め、コメントドック全件整備を含めない。
- 性能基準・計測`BARE-006` / `BARE-007`、storage再設計・View寿命・strict恒久適用`ARRAY-001`は、
  ユーザードキュメント作業後の1.0判断側として凍結を維持する。
- 2026-10-09 11:40 JSTまではClaudeへのassignmentを停止する。`BARE-002`が`ACTIVE`でも、それ以前には
  割り当てない。

`BARE-006`では、Permutation等で確立したRelease、同一環境、base / HEAD比較、回帰判定、artifact保存を
共通基盤として再利用する。一方、BareArrayには既存benchmarkがないため、対象操作、1D〜4DとViewの範囲、
size、Swift Array・unsafe buffer・C配列等の比較対象、絶対性能と回帰性能のどちらを評価するかを新たに
整理する。比較対象や採用閾値が公開上の約束または1.0採否を左右する場合は、Codexが結論を補わず、
一判断ごとの`DECISION`候補として分離する。確定した測定設計と必要な判断を入力に`BARE-007`を実行する。

OptionalArrayの品質評価は、PermutationModuleの`QualityAssessment-ISO25010.md`と同様に、仕様を再記述せず
Test as Specification、実装、CI、利用者向け文書を根拠としてISO/IEC 25010の品質特性ごとに整理する。
体系監査完了時に初版を策定して文書作業と1.0準備の不足を発見し、ユーザードキュメント作業後に再評価する。
後者で残った不足を独立task候補へ分離してから1.0採用判断へ進み、初版だけを品質ゲートの最終評価にしない。

#### 監査開始前の暫定受入基準

現物確認時点の対象は、`OptinalArray.swift` 1ファイルにある所有型1D〜4DとView 1D〜3Dの公開7型・
公開宣言29件、および`OptionalArrayModuleTests`の10ファイル（番号付き仕様test 8、利用例2）とする。
体系監査から文書作業へ渡すには、
次をすべて満たす。

- 公開宣言を全件列挙し、境界、所有、寿命、破棄、変更、`Sendable`、次元の契約を確認する。
- 各契約を既存test、利用例、git履歴上の決定と対応付け、事実、過去判断、現在の推論を区別する。
- OptionalArrayとBareArrayは比較対象にするが、類似実装だけを根拠に同一契約とは扱わない。
- 未検証契約、重複test、仕様を表さないtestを識別し、Test as Specification整理の入力にする。
- 新しい判断点は位置づけ、名称、公開契約など一判断ごとの`DECISION`候補へ分離し、agentが結論を補わない。
- 引き渡し時に、公開契約表、test根拠対応、決定済み事項、未決定事項、利用者向け文書への入力を検収する。
- 利用者向け本文とコメントドック全件整備、および`ARRAY-001`のstorage再設計・strict恒久適用は含めない。

実監査は、公開宣言・履歴の監査とtest根拠の対応監査を独立して開始する。その結果を受けて名称・次元体系を
比較し、判断taskの登録、Test as Specification整理、引き渡し判定の順に閉じる。監査後には、この暫定基準を
実績に照らして再利用可能な管理方式と受入基準へ更新する。

- AcCollections: RedBlackTreeCollections、PermutationModule、OptionalArrayModule、
  BareArrayModuleの再公開テストを追加済み。互換modeでは旧名RedBlackTreeModuleも再公開する。
  別テストターゲットでもRedBlackTreeのDebug寿命カウンタを各テスト後に検査・初期化する。
- PermutationModule: `swift-algorithms`の`permutations()`と重複する全順列列挙系
  (`unsafePermutations()`/`Permutations.All`/`IteratorA`/`SubSequenceA`)と、
  `unsafe`系の公開初期化経路(`unsafeNextPermutations()`、`Nexts.init(safe:)`/
  `init(unsafe:)`)を削除済み(Phase 1A: swift-algorithmsとの等価性PoCで7ケース
  完全一致を確認し削除ゲート通過→Phase 1B: `nextPermutations()`の保持契約テストを
  先に追加してから削除)。公開APIは`nextPermutations()`のみに収束。関連3文書
  (`Specification.md`/`ImplementationPlan.md`/`ProductReadinessAssessment.md`)を
  実装済みAPIへ合わせて書き直し済み。通常/`COMPATIBLE_ATCODER_2025`両方で
  `swift test`成功、`Package.swift`は元の状態へ復元済み。
- REFACTORING_FROM_ATCODER_2025.md: `CLAUDE_TASK.md`の8項目の訂正要件を`git`で
  再検証(全コミットのハッシュ・日付・`-M`判定・`diff`行数・`merge-base`を再確認)し、
  いずれも既に正確であることを確認済み(今回の文書自体への追加修正なし)。
- RedBlackTree: 4型、共有View、BoundExpressionの連番Test as Specification整理済み。
- Index世代、KeyOnly/KeyValue Range ViewのCoW後Index寿命、および4型とRange Viewの
  `elementsEqual(_:)` / `lexicographicallyPrecedes(_:)` は横展開済み。
- `__tree`: 専用ターゲット化、独立レビュー、通常到達可能行のcoverage確認済み。
- `unranged()`およびその専用プロトコル(`ScalarBaseInit`/`KeyValueBaseInit`、
  `_create(_:)`、4型への適合)を削除済み。4型の専用テスト4件も削除し、
  `API-Matrix.md`/`API-Matrix-View.md`/`MAINTENANCE.md`のユーザー要望欄も
  更新済み。通常/`COMPATIBLE_ATCODER_2025`両方で`swift test`成功
  (削除対象は元々`#if !COMPATIBLE_ATCODER_2025`配下のみ)。

## 判断待ち

- PermutationModule: `Sendable`はSwift 6以降で対応する方針で確定済み。第1バッチ
  (`Permutations`と`Nexts where C: Sendable`、コンパイル時テスト)は実装・検証済み。
  共有CoW bufferを持つ`IteratorN`/`SubSequenceN`も、Bufferの`final`化、変更前detachの
  根拠コメント、Taskを跨ぐ回帰テストとともに対応済み(`Maintanance/StrictMemorySafetyReadiness.md`
  §9)。`All`系・`unsafe`系の削除、
  `Tests/PermutationTests/NextPermutation.swift`(未参照の旧世代実装)の削除、
  `nextPermutations()`と公開戻り値型への`///`コメントドック整備は完了済み。
  `.strictMemorySafety()`も恒久適用済みで、対象モジュールの警告0件を確認した。
- 内部テスト層の区分と生木テストの責務整理は、TestSupport/DebugAdditionalsおよび
  UnsafeNode/RawBufferの整理で完了した。
- UnsafeNode/RawBufferのテスト層は統合しない。単層テストはテスト内の算術から期待値を
  独立計算し、`MemoryLayout`、UnsafeNodeの移動・payload位置、Bucket全体の所有byte、
  queue/accessor/traverser間のstrideをそれぞれ検証する。層間クロスチェックは、別実装の
  reference計算とRawBuffer計算、および各要素位置が一致することを複数型・容量で検証する。
  fixtureやproduction helperへ期待値算術を共有すると同じ誤りで両辺が一致し得るため、
  helperとpayload matrixの重複は意図的に維持する。
  stride一致の重複assertionは型範囲の広さのため残す。`RawBufferHeadFixture`がproductionの
  `pairLayout.alignment`ではなく同じ分岐結果になるpayload alignmentを渡す差異は、必要に
  なった場合だけ直す凍結中の任意改善とする。
- `RedBlackTreeTestSupport`は自動テストから呼ばれるfixture・assertion・invariant・test-only
  accessor等の再利用基盤、`DebugAdditionals`は人間向けdump/Graphvizと凍結した旧実験を置く。
  `_LazyTieWrap+Debug.swift`と`unsafe_node+debug.swift`は自動テストから使われるが、現配置を
  文書化された例外として許容し、移動だけを目的とする作業は行わない。
  `TransitionFromLegacy/`、`ThreeWay+Old/`、無効化されたUnsafeTree debug/fixture群、
  `_NodePtr_.swift`内の`#if false`部は、ユーザーが再開を決めるまで凍結する。
- 未結線コードは段階的に削除する方針だが、個々の削除はユーザーが決定し、再開指示まで
  凍結する: `_Reverse4`関連、`swap_key`/`swap_mapped_value`、`outOfRange`/`keyMismatch`、
  `payloadLayout`/`__root_ptr()`、RawRangeの`contains(range:pointer:)`、`_TrackingTag.retire`。

## 凍結・AI再開禁止

- ABC328E実提出による性能検証は、ユーザーが手作業で行う専任項目として凍結する。
  AIは着手・代行・催促しない。詳細は
  `Maintanance/PermutationModule/ImplementationPlan.md`を参照する。

## 直近の引き継ぎ

- runtime-check方針に沿い、コンテナと共有Viewの空remove Death Testを通常構成と
  `_O_UNCHECKED`で確認した。後者で停止しないことは仕様どおりで、テストへの構成guardは加えない。
- `index(inserting:)` / `erase(exactly:)`の4型横展開と、Bound-range eraseの逆順範囲・空コレクションの
  仕様化をTest as Specification先行で完了し、空時の不要なCoWを修正した。
- Index-range eraseの空guard(`RBT-002`)を完了した。4型の`_16`に「空でCoWしない」仕様(修正前に失敗を確認)、
  `_99`に「空でも他木の範囲はtrap」のDeath Testを追加。範囲検査は維持している。
- Index完了ゲートの検証として、4型の`_1`に走査の比較回数の仕様(全走査・前後走査・範囲走査は0回、範囲作成は1回)、
  Dictionary / MultiMapの`_98_CopyOnWrite`にKeyValue Range Viewの`erase(where:)` CoWを追加した。
  Debug限定Balanced群に依存していた`RedBlackTreeMultiMap_8`のテストは`_98_DebugOnlyAPITests`へ移した。
  `RedBlackTreeSet_9`の`test_index_comparable`はDebug限定Index `Comparable`依存のまま、`RBT-011`待ち。
- PR #158前のIndex(`_LazyTieWrappedPtr`)向けの未使用宣言は、削除を保留して
  `DebugAdditionals/UnsafeTreeV2+Debug/_LazyTieWrappedPtr+Retired.swift`へ待避した。
  4構成ビルドとDebug / Releaseの`swift test`は成功。LinuxのCIはpush後に確認する。

最終更新: 2026-10-08 / Codex

このファイルは現在地を上書きして保つ。長文報告や年代順ログは追加せず、引き継ぎは
最大5項目とする。ユーザー方針の変更・削除はユーザーへ確認する。
